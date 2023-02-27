# frozen_string_literal: true
require 'active_fedora'
require 'tufts/transcript_utils'

namespace :tufts do
  desc 'change https to http in the rights_statement attribute of all DL objects'

  task :fix_transcript_relationships, [:offset] => [:environment] do |_t, args|
    if args[:offset].nil?
      puts('example usage: rake tufts:fix_transcript_relationships[offset]')
    else
      start_index = args[:offset].to_i
      rows = '50000'
      Tufts::TranscriptUtils.update_index(start_index, rows)
    end
  end
end
