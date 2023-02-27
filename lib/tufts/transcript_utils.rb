# frozen_string_literal: true
module Tufts
  module TranscriptUtils
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Rails/Output
    def self.update_index(start_index, rows)
      solr_connection = ActiveFedora.solr.conn
      response = solr_connection.get('select', params: { fq: 'has_model_ssim:Video OR has_model_ssim:Audio', fl:
      'id', rows: rows.to_s, start: 0, defType: 'edismax' })

      loop_index = 0
      go_again = response["response"]["numFound"] > rows.to_i + start_index

      while loop_index < response["response"]["docs"].length
        id = response["response"]["docs"][loop_index]["id"]
        puts "beginning to update #{id} , record #{loop_index}"
        object = ActiveFedora::Base.find(id)
        if !object.transcript_id.nil?
          object.update_index
          object.save
          puts "updated #{id}"
        else
          puts "no transcript #{id}"
        end

        loop_index += 1
        # save last index start_index + loop_index
        File.open("index_fix_index.txt", 'w') { |file| file.write((start_index + loop_index)) }
      end

      go_again && update_index(start_index + loop_index, rows)
    end
  end
end
