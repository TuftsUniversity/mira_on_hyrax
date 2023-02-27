module Tufts
  module TranscriptUtils
    def self.update_index(start_index, rows)

      solr_connection = ActiveFedora.solr.conn
      response = solr_connection.get('select', params: { q: 'has_model_ssim:Video', fl: 'id', rows: rows.to_s, start: start_index.to_s })

      ids = Array.new

      numFound = response["response"]["numFound"]
      puts "records found: #{numFound}"
      loop_index = 0
      #go_again = numFound == rows.to_i

      while loop_index < numFound
        id = response["response"]["docs"][loop_index]["id"]
        Rails.logger.info "beginning to update #{id} , record #{loop_index}"
        object = ActiveFedora::Base.find(id)
        if object.transcript_id != nil
          object.update_index
          object.save
          puts "updated #{id}"
        else
          puts "no transcript #{id}"
        end

        loop_index += 1
        # save last index start_index + loop_index
        #File.open("index_fix_index.txt", 'w') { |file| file.write((start_index + loop_index)) }
      end


      #if go_again
      #  update_index(start_index + loop_index, rows)
      #end
    end
  end
end