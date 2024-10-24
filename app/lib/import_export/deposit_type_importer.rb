# frozen_string_literal: true
class ImportFileNotFoundError < StandardError; end
class ImportFileFormatError   < StandardError; end

class DepositTypeImporter
  attr_reader :import_file

  def initialize(import_file)
    @import_file = import_file
  end

  def import_from_csv
    log_start_message
    validate_import_file_exists
    validate_import_file_format

    import_options = { headers: :first_row,
                       return_headers: false,
                       skip_blanks: true }
    CSV.foreach(@import_file, import_options) do |row|
      attrs = strip_whitespace(row.to_hash)
      log_row_message(attrs)
      dt = DepositType.where(display_name: attrs['display_name']).first_or_create
      dt.update!(attrs)
    end

    log_end_message
  end

protected

  def log_start_message
    Rails.logger.info "Importing deposit types from file: #{@import_file}"
  end

  def log_row_message(row)
    Rails.logger.info "  Deposit type: #{row['display_name']}"
  end

  def log_end_message
    Rails.logger.info 'Finished importing deposit types'
  end

  def validate_import_file_exists
    raise ImportFileNotFoundError, @import_file unless File.exist?(@import_file)
  end

  def validate_import_file_format
    raise ImportFileFormatError, 'Must be a *.csv file' unless /^.*\.csv$/i.match?(@import_file)
  end

  def strip_whitespace(hash)
    clean_hash = {}
    hash.each_pair { |k, v| (clean_hash[k] = v.strip) if v }
    clean_hash
  end
end
