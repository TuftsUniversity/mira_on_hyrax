# frozen_string_literal: true
namespace :import do
  desc 'Ingest files from public remote URLs using XML metadata and a CSV manifest from local paths or URLs'
  task remote_url: :environment do
    xml_path = ENV['XML']
    manifest_path = ENV['MANIFEST']
    username = ENV.fetch('USER', 'cli_user')
    import_id = ENV['IMPORT_ID']
    batch_size = ENV.fetch('BATCH_SIZE', '25')
    download_retries = ENV.fetch('DOWNLOAD_RETRIES', '3')

    if manifest_path.blank? || (xml_path.blank? && import_id.blank?)
      puts(
        'Usage: rake import:remote_url XML=/path/or/url/to/import.xml ' \
        'MANIFEST=/path/or/url/to/manifest.csv USER=cli_user'
      )
      puts(
        'Resume an existing import with: rake import:remote_url IMPORT_ID=123 ' \
        'MANIFEST=/path/or/url/to/manifest.csv USER=cli_user'
      )
      next
    end

    result = Tufts::RemoteUrlIngestService.run!(xml_path: xml_path,
                                                manifest_path: manifest_path,
                                                username: username,
                                                import_id: import_id,
                                                batch_size: batch_size,
                                                download_retries: download_retries)

    puts "Finished XmlImport ##{result[:import_id]}"
    puts "Run directory: #{result[:run_directory]}"
  end

  desc 'Deprecated alias for import:remote_url'
  task box_audio: :environment do
    puts 'DEPRECATED: use rake import:remote_url instead of rake import:box_audio'
    Rake::Task['import:remote_url'].invoke
  end
end
