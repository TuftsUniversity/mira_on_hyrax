# frozen_string_literal: true

namespace :tdr do
  desc 'Starts fixity check on all files'
  task fixity_check: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_random_sampling
  end

  desc 'fixity everything'
  task fixity_everything: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_everything
  end

  desc 'run fixity for a particular id'
  task :fixity_by_id, [:id] => :environment do |_task, args|
    fs_id = args[:id]
    raise "ERROR: no work id specified, aborting" if fs_id.nil?
    ::Hyrax::RepositoryFixityCheckService.fixity_check_fileset(fs_id)
    puts "Fixity checked for fileset id #{fs_id}"
  end

  desc 'run fixity for a particular object id'
  task :fixity_by_object_id, [:id] => :environment do |_task, args|
    work_id = args[:id]
    work = ActiveFedora::Base.find(work_id)
    work.file_sets.each do |file_set|
      ::Hyrax::RepositoryFixityCheckService.fixity_check_fileset(file_set.id)
      puts "Fixity checked for fileset id #{file_set.id} belonging to #{work_id}"
    end
  end


end
