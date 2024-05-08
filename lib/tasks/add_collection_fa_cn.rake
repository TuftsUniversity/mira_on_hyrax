# frozen_string_literal: true
require 'active_fedora'

namespace :tufts do
  desc "Add Archives@Tufts Finding Aid URL and Call Number to collections."

  task add_collection_fa_cn: :environment do
    debug        = false # turn this on to echo each line of input after parsing it.
    save_updates = true # turn this off to run the task to see what it will do, without saving changes to MIRA.

    # The first time Collection.first is called, it causes a deprecation warning;  calling Collection.first here
    # causes the deprecation warning to happen at the top of the task's output so that no legitimate error messages
    # get lost in between the deprecation warnings.  It doesn't matter if the collection is actually found or not.
    begin
      Collection.where(title: "Foobar").first # returns an empty ActiveFedora::Relation
    rescue StandardError => ex
      puts("\nError when calling Collection.first: #{ex}.")
      exit
    end

    puts("") # Leave a blank line after all the deprecation warnings.

    unless ARGV.size == 2
      puts("example usage: bundle exec rake tufts:add_collection_fa_cn collection_info.csv")
      exit
    end

    filename = ARGV[1]
    csv_file = open(filename)
    column_names = csv_file.first.strip.split(",")

    unless column_names.length == 3 && column_names[0] == "finding aid link" && column_names[1] == "collection number" && column_names[2] == "collection title"
      puts("The first line of #{filename} should contain three comma-separated column names: finding aid link,collection number,collection title.")
      exit
    end

    puts("line 1: #{column_names}") if debug

    # These hash tables are used to check for duplicates.  The key is the value from the corresponding column of the CSV file, and the value is the line number within the CSV file.
    finding_aid_links = {}
    call_numbers      = {}
    collection_titles = {}
    lines             = {}
    errors            = []
    not_found         = []
    found_multiple    = []

    csv_file.each.with_index(2) do |line, line_number|
      row_values = line.strip.split(',', 3) # split the line into three values on the first two commas

      unless row_values.length == 3 && row_values[2].present?
        errors.append("Line #{line_number} of #{filename} should contain three comma-separated values.")
        next
      end

      # For the third value, remove leading/trailing quotes and replace two consecutive quotes with one quote.
      row_values[2] = row_values[2].delete_prefix('"').delete_suffix('"').gsub('""', '"')

      puts("line #{line_number}: #{row_values}") if debug

      finding_aid_link = row_values[0]
      call_number      = row_values[1]
      collection_title = row_values[2]

      # Check for previous lines with duplicate values.
      dup_finding_aid_link_line_number = finding_aid_links[finding_aid_link]
      dup_call_number_line_number      = call_numbers[call_number]
      dup_collection_title_line_number = collection_titles[collection_title]

      if dup_finding_aid_link_line_number.nil?
        finding_aid_links[finding_aid_link] = line_number
      else
        lines.delete(dup_finding_aid_link_line_number)
        errors.append("Lines #{dup_finding_aid_link_line_number} and #{line_number} of #{filename} contain duplicate finding aid links: #{finding_aid_link}.")
      end

      if dup_call_number_line_number.nil?
        call_numbers[call_number] = line_number
      else
        lines.delete(dup_call_number_line_number)
        errors.append("Lines #{dup_call_number_line_number} and #{line_number} of #{filename} contain duplicate collection numbers: #{call_number}.")
      end

      if dup_collection_title_line_number.nil?
        collection_titles[collection_title] = line_number
      else
        lines.delete(dup_collection_title_line_number)
        errors.append("Lines #{dup_collection_title_line_number} and #{line_number} of #{filename} contain duplicate collection titles: #{collection_title}.")
      end

      if dup_finding_aid_link_line_number.nil? && dup_call_number_line_number.nil? && dup_collection_title_line_number.nil?
        lines[line_number] = { finding_aid_link: finding_aid_link, call_number: call_number, collection_title: collection_title }
      end
    rescue StandardError => ex
      errors.append("Check line #{line_number} of #{filename} for errors: #{ex}.")
    end

    line_numbers = lines.keys.sort

    line_numbers.each do |line_number|
      line = lines[line_number]
      collection_title = line[:collection_title]
      collections = Collection.where(title: collection_title)
      matching_collections = []

      # There may be multiple collections that sort of match this title;  ignore any that aren't an exact match.
      # Ignore case, because there are many collections in MIRA with titles like "Something Or Somebody records or papers" that should be
      # "Something Or Somebody Records Or Papers" with a capital R or P.

      collections.each do |collection|
        matching_collections.append(collection) if collection[:title].first.casecmp(collection_title).zero?
      end

      if matching_collections.empty?
        not_found.append("The collection #{line[:collection_title]} on line #{line_number} of #{filename} is not found in MIRA.")

        unless collections.empty?
          not_found.append("    Maybe the title of #{collections.length == 1 ? 'this collection' : 'one of these collections'} is misspelled in MIRA:")

          collections.each do |collection|
            not_found.append("    #{collection.id}  #{collection[:title].first}")
          end
        end
      elsif matching_collections.length > 1
        found_multiple.append("The title #{line[:collection_title]} on line #{line_number} of #{filename} matches #{matching_collections.length} collections:")

        matching_collections.each do |collection|
          found_multiple.append("    #{collection.id}  #{collection[:title].first}")
        end
      else
        collection              = matching_collections.first
        old_call_number         = collection[:call_number].first
        old_finding_aid_link    = collection[:finding_aid].first
        new_call_number         = line[:call_number]
        new_finding_aid_link    = line[:finding_aid_link]
        update_call_number      = new_call_number      != old_call_number
        update_finding_aid_link = new_finding_aid_link != old_finding_aid_link

        if update_call_number || update_finding_aid_link
          puts("#{save_updates ? 'Updating' : 'Would update'} collection #{collection_title}  old call number: #{old_call_number}  "\
            "old finding aid link: #{old_finding_aid_link}  new call number: #{new_call_number}  new finding aid link: #{new_finding_aid_link}.")

          collection[:call_number] = [new_call_number]      if update_call_number
          collection[:finding_aid] = [new_finding_aid_link] if update_finding_aid_link
          collection.save!                                  if save_updates
        else
          puts("Collection #{collection_title} already has call number #{new_call_number} and finding aid link #{new_finding_aid_link};  no need to update.")
        end
      end
    rescue StandardError => ex
      errors.append("Error updating line #{line_number} of #{filename}: #{ex}.")
    end

    # Output all the error messages after all the processing has been done.
    puts("") unless errors.empty?
    errors.each do |error|
      puts(error)
    end

    puts("") unless not_found.empty?
    not_found.each do |error|
      puts(error)
    end

    puts("") unless found_multiple.empty?
    found_multiple.each do |error|
      puts(error)
    end
  end
end
