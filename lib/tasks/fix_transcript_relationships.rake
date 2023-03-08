# frozen_string_literal: true
require 'active_fedora'
require 'tufts/transcript_utils'

namespace :tufts do
  desc 'updates index for all av objects with transcripts'

  task :fix_transcript_relationships, [:offset] => [:environment] do |_t, args|
    if args[:offset].nil?
      puts('example usage: rake tufts:fix_transcript_relationships[offset]')
    else
      Rails.logger = Logger.new(STDOUT)
      start_index = args[:offset].to_i
      rows = '50000'
      Tufts::TranscriptUtils.update_index(start_index, rows)
    end
  end
end
