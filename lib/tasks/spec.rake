# frozen_string_literal: true
unless Rails.env.production?
  require 'solr_wrapper/rake_task'

  namespace :tufts do
    task spec: :environment do
      with_server 'test' do
        Rake::Task['spec'].invoke
      end
    end
  end
end
