# frozen_string_literal: true
module Tufts
  module TranscriptUtils
    def self.update_index(start_index, rows)
      response = av_ids(rows)

      loop_index = 0

      docs = response["response"]["docs"]

      while loop_index < docs.length
        doc = docs[loop_index]
        id = doc["id"]
        Rails.logger.info "beginning to update #{id} , record #{loop_index}"
        conditionally_update_record(id)

        loop_index += 1

        # save last index start_index + loop_index
        File.open("index_fix_index.txt", 'w') { |file| file.write((start_index + loop_index)) }
      end

      go_again?(start_index, rows, response["response"]["numFound"]) && update_index(start_index + loop_index, rows)
    end

    private

    def self.go_again?(start_index, rows, num_found)
      num_found > rows.to_i + start_index
    end

    def self.av_ids(rows)
      solr_connection = ActiveFedora.solr.conn
      solr_connection.get('select', params: { fq: 'has_model_ssim:Video OR has_model_ssim:Audio', fl:
      'id', rows: rows.to_s, start: 0, defType: 'edismax' })
    end

    def self.conditionally_update_record(id)
      object = ActiveFedora::Base.find(id)
      if !object.transcript_id.nil?
        object.update_index
        object.save
        Rails.logger.info "updated #{id}"
      else
        Rails.logger.info "no transcript #{id}"
      end
    end
  end
end
