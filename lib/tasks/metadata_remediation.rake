# frozen_string_literal: true
require 'rake'

namespace :tdr do
  # previously called scattering, used for replacing the term scattering with scattering votes, now
  # generalized for replacing metadata in any field assumes array not for use on single value fields
  desc "replace_metadata"
  task :replace_metadata, [:file_name] => [:environment] do |_t, args|
    file_name = args[:file_name]
    puts "Loading File #{file_name}"
    CSV.foreach(file_name, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
      pid = row[0]
      puts pid.to_s
      field = row[1]
      field_sym = field.parameterize.underscore.to_sym
      field_sym_setter = field.parameterize
      field_sym_setter = (field_sym_setter + "=").underscore.to_sym
      val_to_replace = row[2]
      replacement_value = row[3]
      a = ActiveFedora::Base.find(pid)
      names = a.send(field_sym)
      names = names.to_a
      names.delete(val_to_replace)
      names.push(replacement_value)
      a.send(field_sym_setter, names)
      puts "Updating #{pid} from #{field} to #{names}"
      a.save!
    end
  end
  # previously called scattering, used for replacing the term scattering with scattering votes, now
  # generalized for replacing metadata in any field assumes array not for use on single value fields
  desc "blank_out_field"
  task :blank_out_field, [:file_name] => [:environment] do |_t, args|
    file_name = args[:file_name]
    puts "Loading File #{file_name}"
    CSV.foreach(file_name, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
      pid = row[0]
      puts pid.to_s
      field = row[1]
      field_sym_setter = field.parameterize
      field_sym_setter = (field_sym_setter + "=").underscore.to_sym
      begin
        a = ActiveFedora::Base.find(pid)
      rescue
        puts "WARN: Can't find #{pid}, skipping.."
        next
      end
      names = []
      a.send(field_sym_setter, names)
      puts "Updating #{pid} from #{field} to #{names}"
      a.save!
    end
  end

  # previously called scattering, used for replacing the term scattering with scattering votes, now
  # generalized for replacing metadata in any field assumes array not for use on single value fields
  desc "delete_value"
  task :delete_value, [:file_name] => [:environment] do |_t, args|
    file_name = args[:file_name]
    puts "Loading File #{file_name}"
    CSV.foreach(file_name, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
      pid = row[0]
      puts pid.to_s
      field = row[1]
      field_sym = field.parameterize.underscore.to_sym
      field_sym_setter = field.parameterize
      field_sym_setter = (field_sym_setter + "=").underscore.to_sym
      val_to_replace = row[2]
      a = ActiveFedora::Base.find(pid)
      names = a.send(field_sym)
      names = names.to_a
      names.delete(val_to_replace)
      a.send(field_sym_setter, names)
      puts "Updating #{pid} from #{field} to #{names}"
      a.save!
    end
  end
end
