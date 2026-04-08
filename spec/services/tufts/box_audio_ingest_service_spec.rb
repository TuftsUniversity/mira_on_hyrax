# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tufts::BoxAudioIngestService, :batch, :clean, :workflow do
  let!(:user) { FactoryBot.create(:user, username: 'cli_user') }
  let(:xml_path) { file_fixture('mira_xml_file_types.xml').to_s }
  let(:progress_io) { StringIO.new }
  let(:manifest_file) do
    Tempfile.new(['box_audio_manifest', '.csv']).tap do |file|
      file.write("filename,box_url\n")
      file.write("pdf-sample.pdf,https://box.example.test/pdf-sample.pdf\n")
      file.write("2.pdf,https://box.example.test/2.pdf\n")
      file.rewind
    end
  end

  before do
    ActiveJob::Base.queue_adapter = :test

    allow(Tufts::RemoteFileDownloadService).to receive(:download!) do |url:, destination_path:, **_kwargs|
      source_filename = File.basename(url)
      FileUtils.cp(file_fixture(source_filename), destination_path)
      destination_path
    end
  end

  after do
    manifest_file.close
    manifest_file.unlink
  end

  it 'creates an XmlImport and enqueues ingest jobs for ready records' do
    result = nil

    expect do
      result = described_class.run!(xml_path: xml_path,
                                    manifest_path: manifest_file.path,
                                    username: user.username,
                                    batch_size: 2,
                                    progress_io: progress_io)
    end.to enqueue_job(ImportJob).exactly(:once)

    import = XmlImport.find(result[:import_id])

    expect(import.uploaded_files.map { |file| file.file.file.filename })
      .to contain_exactly('pdf-sample.pdf', '2.pdf')
    expect(import.record_ids.keys).to contain_exactly('pdf-sample.pdf')
    expect(result).to include(downloaded: 2, submitted: 2, skipped: 0, failed: 0)
    expect(File.exist?(File.join(result[:run_directory], 'results.csv'))).to be(true)
  end

  it 'skips rows already uploaded when resuming an existing import' do
    initial_result = described_class.run!(xml_path: xml_path,
                                          manifest_path: manifest_file.path,
                                          username: user.username,
                                          batch_size: 2,
                                          progress_io: progress_io)

    expect do
      @resumed_result = described_class.run!(xml_path: xml_path,
                                             manifest_path: manifest_file.path,
                                             username: user.username,
                                             import_id: initial_result[:import_id],
                                             batch_size: 2,
                                             progress_io: progress_io)
    end.not_to enqueue_job(ImportJob)

    expect(@resumed_result).to include(downloaded: 0, submitted: 0, skipped: 2, failed: 0)
  end
end
