# frozen_string_literal: true
namespace :import do
  desc 'Ingest audio files from public Box URLs using XML metadata and a CSV manifest'
  task box_audio: :environment do
    xml_path = ENV['XML']
    manifest_path = ENV['MANIFEST']
    username = ENV.fetch('USER', 'cli_user')
    import_id = ENV['IMPORT_ID']
    batch_size = ENV.fetch('BATCH_SIZE', '25')
    download_retries = ENV.fetch('DOWNLOAD_RETRIES', '3')

    if manifest_path.blank? || (xml_path.blank? && import_id.blank?)
      puts 'Usage: rake import:box_audio XML=/path/to/import.xml MANIFEST=/path/to/manifest.csv USER=cli_user'
      puts 'Resume an existing import with: rake import:box_audio IMPORT_ID=123 MANIFEST=/path/to/manifest.csv USER=cli_user'
      next
    end

    result = Tufts::BoxAudioIngestService.run!(xml_path: xml_path,
                                               manifest_path: manifest_path,
                                               username: username,
                                               import_id: import_id,
                                               batch_size: batch_size,
                                               download_retries: download_retries)

    puts "Finished XmlImport ##{result[:import_id]}"
    puts "Run directory: #{result[:run_directory]}"
  end
end
