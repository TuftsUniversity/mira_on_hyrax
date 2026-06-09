# frozen_string_literal: true
require 'rails_helper'
require 'rake'

RSpec.describe 'import:remote_url', type: :rake do
  let(:task_file) { File.expand_path('../../../../lib/tasks/import_remote_url.rake', __FILE__) }

  before do
    load_rake_environment [task_file]
  end

  around do |example|
    original_env = ENV.to_hash
    example.run
    ENV.replace(original_env)
  end

  it 'prints usage when required inputs are missing' do
    stdout = run_task('import:remote_url')

    expect(stdout).to include('Usage: rake import:remote_url XML=/path/to/import.xml MANIFEST=/path/to/manifest.csv USER=cli_user')
  end

  it 'invokes the ingest service with environment variables' do
    allow(Tufts::RemoteUrlIngestService).to receive(:run!)
      .and_return(import_id: 123, run_directory: '/tmp/remote_url_ingest/xml_import_123')

    set_task_environment
    expect_task_output(run_task('import:remote_url'))
  end

  def expected_run_arguments
    {
      xml_path: '/tmp/import.xml',
      manifest_path: '/tmp/manifest.csv',
      username: 'cli_user',
      import_id: nil,
      batch_size: '10',
      download_retries: '4'
    }
  end

  def expect_task_output(stdout)
    expect(Tufts::RemoteUrlIngestService).to have_received(:run!).with(expected_run_arguments)
    expect(stdout).to include('Finished XmlImport #123')
    expect(stdout).to include('Run directory: /tmp/remote_url_ingest/xml_import_123')
  end

  def set_task_environment
    ENV.update('XML' => '/tmp/import.xml',
               'MANIFEST' => '/tmp/manifest.csv',
               'USER' => 'cli_user',
               'BATCH_SIZE' => '10',
               'DOWNLOAD_RETRIES' => '4')
  end
end
