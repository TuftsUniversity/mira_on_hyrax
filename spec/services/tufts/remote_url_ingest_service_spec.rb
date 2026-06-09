# frozen_string_literal: true
# rubocop:disable RSpec/ExampleLength
require 'rails_helper'

RSpec.describe Tufts::RemoteUrlIngestService, :batch, :clean, :workflow do
  let!(:user) { FactoryBot.create(:user, username: 'cli_user') }
  let(:xml_path) { file_fixture('mira_xml_file_types.xml').to_s }
  let(:progress_io) { StringIO.new }
  let(:manifest_file) do
    Tempfile.new(['remote_url_manifest', '.csv']).tap do |file|
      file.write("filename,remote_url\n")
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

  it 'logs to progress output when setup fails before the run logger is built' do
    with_invalid_xml_file do |invalid_xml|
      expect { described_class.run!(**run_arguments(xml_path: invalid_xml.path)) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    expect(progress_io.string)
      .to include('Remote URL ingest failed for XmlImport #new: ActiveRecord::RecordInvalid')
  end

  it 'creates an XmlImport and enqueues ingest jobs for ready records' do
    expect { run_service }.to enqueue_job(ImportJob).exactly(:once)
    expect_completed_import
  end

  it 'skips rows already uploaded when resuming an existing import' do
    initial_result = run_service
    resumed_result = nil

    expect { resumed_result = resume_service(initial_result[:import_id]) }.not_to enqueue_job(ImportJob)
    expect_resumed_result(resumed_result)
  end

  def expect_completed_import
    expect_uploaded_files
    expect_record_ids
    expect_summary
    expect_results_file
  end

  def expect_resumed_result(result)
    expect(result.fetch(:skipped)).to eq(2)
    expect(result.fetch(:rows)).to eq(2)
    expect(result[:downloaded]).to eq(0)
    expect(result[:submitted]).to eq(0)
    expect(result[:failed]).to eq(0)
  end

  def expect_uploaded_files
    expect(import.uploaded_files.map { |file| file.file.file.filename })
      .to contain_exactly('pdf-sample.pdf', '2.pdf')
  end

  def expect_record_ids
    expect(import.record_ids.keys).to contain_exactly('2.pdf')
  end

  def expect_summary
    expect(result).to include(downloaded: 2, submitted: 2)
    expect(result[:skipped]).to eq(0)
    expect(result[:failed]).to eq(0)
  end

  def expect_results_file
    expect(File.exist?(File.join(result[:run_directory], 'results.csv'))).to be(true)
  end

  def invalid_xml_content
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/">
        <ListRecords>
          <record>
            <metadata>
              <mira_import xmlns:model="info:fedora/fedora-system:def/model#"
                           xmlns:dc="http://purl.org/dc/terms/"
                           xmlns:tufts="http://dl.tufts.edu/terms#">
                <tufts:filename>bad.wav</tufts:filename>
                <dc:title>Bad Record</dc:title>
                <tufts:visibility></tufts:visibility>
                <model:hasModel>Audio</model:hasModel>
                <tufts:displays_in>dl</tufts:displays_in>
              </mira_import>
            </metadata>
          </record>
        </ListRecords>
      </OAI-PMH>
    XML
  end

  def import
    XmlImport.find(result[:import_id])
  end

  def result
    @result ||= run_service
  end

  def resume_service(import_id)
    described_class.run!(**run_arguments(import_id: import_id))
  end

  def run_service
    described_class.run!(**run_arguments)
  end

  def with_invalid_xml_file
    invalid_xml = Tempfile.new(['invalid_remote_url', '.xml'])
    invalid_xml.write(invalid_xml_content)
    invalid_xml.rewind
    yield invalid_xml
  ensure
    invalid_xml.close
    invalid_xml.unlink
  end

  def run_arguments(import_id: nil, xml_path: self.xml_path)
    {
      xml_path: xml_path,
      manifest_path: manifest_file.path,
      username: user.username,
      import_id: import_id,
      batch_size: 2,
      progress_io: progress_io
    }
  end
end
# rubocop:enable RSpec/ExampleLength
