require 'rails_helper'

puts "test"
rows = '50000'

start_index = 0
if File.exists?("index_fix_index.txt") 
  File.open("index_fix_index.txt") { start_index = file.read.to_i }
end

def update_index(start_index, rows)
  puts "Bang"
  solr_connection = ActiveFedora.solr.con
  response = solr_connection.get('select', params: { q: 'has_model_ssim:Video OR has_model_ssim:Audio', fl: 'id', rows: rows.to_s, start: start_index.to_s })

  ids = Array.new

  numFound = response["response"]["numFound"]
  loop_index = 0
  go_again = numFound == rows.to_i 

  while loop_index < numFound
    object = ActiveFedora::Base.find(response["response"]["docs"][loop_index]["id"])
    if object.transcript_id != nil
      object.update_index
      object.save
    end

    # save last index start_index + loop_index
    File.open("index_fix_index.txt", 'w') { |file| file.write((start_index + loop_index)) }
  end
  puts "Bang"

  if go_again
    update_index(start_index + loop_index, rows)
  end
end

update_index(start_index, rows)



