# frozen_string_literal: true
require 'rails_helper'
require 'rake'

RSpec.describe 'import:box_audio', type: :rake do
  let(:task_file) { File.expand_path('../../../../lib/tasks/import_box_audio.rake', __FILE__) }

  before do
    load_rake_environment [task_file]
  end

  around do |example|
    original_env = ENV.to_hash
    example.run
    ENV.replace(original_env)
  end

  it 'prints usage when required inputs are missing' do
    stdout = run_task('import:box_audio')

    expect(stdout).to include('Usage: rake import:box_audio XML=/path/to/import.xml MANIFEST=/path/to/manifest.csv USER=cli_user')
  end

  it 'invokes the ingest service with environment variables' do
    allow(Tufts::BoxAudioIngestService).to receive(:run!)
      .and_return(import_id: 123, run_directory: '/tmp/box_ingest/xml_import_123')

    ENV['XML'] = '/tmp/import.xml'
    ENV['MANIFEST'] = '/tmp/manifest.csv'
    ENV['USER'] = 'cli_user'
    ENV['BATCH_SIZE'] = '10'
    ENV['DOWNLOAD_RETRIES'] = '4'

    stdout = run_task('import:box_audio')

    expect(Tufts::BoxAudioIngestService).to have_received(:run!).with(xml_path: '/tmp/import.xml',
                                                                      manifest_path: '/tmp/manifest.csv',
                                                                      username: 'cli_user',
                                                                      import_id: nil,
                                                                      batch_size: '10',
                                                                      download_retries: '4')
    expect(stdout).to include('Finished XmlImport #123')
    expect(stdout).to include('Run directory: /tmp/box_ingest/xml_import_123')
  end
end
