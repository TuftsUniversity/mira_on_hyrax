# frozen_string_literal: true
require 'rake'

namespace :tdr do
  desc "unpublish objects"
  task :unpublish_objects, [:object_file] => [:environment] do |_t, args|
    if args[:object_file].nil?
      puts('example usage: rake unpublish_objects /usr/local/samvera/epigaea/unpublish_objects.txt')
    else
      puts "Loading File"
      filename = args[:object_file]
      CSV.foreach(filename, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
        pid = row[0]
        UnpublishJob.perform_later(pid)
      rescue ActiveFedora::ObjectNotFoundError
        puts "ERROR not found #{pid}"
      end
    end
  end

  desc "publish objects"
  task :publish_objects, [:object_file] => [:environment] do |_t, args|
    if args[:object_file].nil?
      puts('example usage: rake publish_objects /usr/local/samvera/epigaea/publish_objects.txt')
    else
      puts "Loading File"
      filename = args[:object_file]
      CSV.foreach(filename, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
        pid = row[0]
        PublishJob.perform_later(pid)
      rescue ActiveFedora::ObjectNotFoundError
        puts "ERROR not found #{pid}"
      end
    end
  end
end
