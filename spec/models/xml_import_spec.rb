# frozen_string_literal: true
require 'rails_helper'

RSpec.describe XmlImport, :batch, :clean, :workflow, type: :model do
  subject(:import) { FactoryBot.build(:xml_import) }

  before do
    allow(Collection).to receive(:find).and_return(true)
    allow(described_class::NOID_SERVICE)
      .to receive(:mint)
      .and_return('123', '124', 'some', 'other', 'id', 'values')
  end

  it_behaves_like 'a batchable' do
    subject(:batchable) do
      FactoryBot.create(:xml_import, uploaded_file_ids: uploads.map(&:id))
    end
    let(:service) { instance_double(::Noid::Rails::Service, mint: noid) }
    let(:noid) { 'wd3763094' }
    let(:uploads) do
      # run these in a different order from the xml to confirm looping logic
      [FactoryBot.create(:hyrax_uploaded_file,
                         file: File.open('spec/fixtures/files/2.pdf')),
       FactoryBot.create(:hyrax_uploaded_file,
                         file: File.open('spec/fixtures/files/3.pdf')),
       FactoryBot.create(:hyrax_uploaded_file)]
    end
  end

  describe '#records' do
    it 'returns ImportRecords' do
      expect(import.records)
        .to contain_exactly(an_instance_of(Tufts::ImportRecord),
                            an_instance_of(Tufts::ImportRecord))
    end

    it 'has the correct records' do
      expect(import.records.map(&:file))
        .to contain_exactly('pdf-sample.pdf', '2.pdf')
    end
  end

  describe '#metadata_file' do
    subject(:import)  { FactoryBot.build(:xml_import, metadata_file: nil) }
    let(:file)        { file_fixture('mira_xml.xml') }

    it 'is an uploader' do
      expect { import.metadata_file = File.open(file) }
        .to change { import.metadata_file }
        .to(an_instance_of(Tufts::MetadataFileUploader))
    end
  end

  describe '#uploaded_file_ids' do
    let(:ids)    { ['1', '2'] }
    let(:upload) { FactoryBot.create(:hyrax_uploaded_file) }

    it 'sets uploaded file ids' do
      expect { import.uploaded_file_ids.concat(ids) }
        .to change { import.uploaded_file_ids }
        .to contain_exactly(*ids)
    end

    it 'validates existence of files for ids' do
      import.uploaded_file_ids = [upload.id]

      expect { import.uploaded_file_ids.concat(ids) }
        .to change { import.valid? }
        .from(true).to(false)
    end
  end

  describe '#uploaded_files' do
    subject(:import) do
      FactoryBot.build(:xml_import, uploaded_file_ids: files.map(&:id))
    end

    let(:files) { FactoryBot.create_list(:hyrax_uploaded_file, 3) }

    it 'has the correct files' do
      expect(import.uploaded_files).to contain_exactly(*files)
    end

    context 'when saved' do
      it 'removes duplicate files' do
        expect { import.save }
          .to change { import.uploaded_files }
          .to contain_exactly(files.first)
      end
    end

    context 'when empty' do
      subject(:import) do
        FactoryBot.create(:xml_import, uploaded_file_ids: [])
      end

      it 'is empty' do
        expect(import.uploaded_files).to be_empty
      end
    end

    context 'with false file ids' do
      before { import.uploaded_file_ids.concat(['false_id']) }

      it 'raises an error' do
        expect { import.uploaded_files }
          .to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#enqueue!' do
    subject(:import) do
      FactoryBot.create(:xml_import, uploaded_file_ids: [file.id])
    end

    let(:file) do
      FactoryBot.create(:hyrax_uploaded_file,
                        file: File.open('spec/fixtures/files/2.pdf'))
    end

    before { ActiveJob::Base.queue_adapter = :test }

    it 'enqueues the correct job type' do
      expect { import.enqueue! }
        .to enqueue_job(ImportJob)
        .with(import, [file], an_instance_of(String))
        .on_queue('batch')
        .once
    end

    it 'does not enqueue jobs for records with no files' do
      expect { import.enqueue! }
        .not_to enqueue_job(ImportJob)
        .with(import, import.records.to_a.last.file, an_instance_of(String))
    end

    context 'when no files have been uploaded' do
      subject(:import) do
        FactoryBot.create(:xml_import, uploaded_file_ids: [])
      end

      it 'gives an empty result' do
        expect(import.enqueue!).to be_empty
      end

      it 'does not enqueue jobs' do
        expect { import.enqueue! }.not_to enqueue_job(ImportJob)
      end
    end

    context 'when a file is re-uploaded' do
      let(:duplicate_file) do
        FactoryBot.create(:hyrax_uploaded_file,
                          file: File.open('spec/fixtures/files/2.pdf'))
      end

      before do
        import.batch.enqueue!
        import.uploaded_file_ids << duplicate_file.id
      end

      it 'does not re-enqueue the job' do
        expect { import.enqueue! }.not_to enqueue_job(ImportJob)
      end
    end
  end

  describe '#record_ids' do
    let(:ids)    { uploads.map(&:id) }
    let(:upload) { FactoryBot.create(:hyrax_uploaded_file) }

    let(:uploads) do
      [upload,
       FactoryBot.create(:hyrax_uploaded_file,
                         file: File.open(file_fixture('3.pdf')))]
    end

    before { import.uploaded_file_ids = ids }

    it 'is empty' do
      expect(import.record_ids).to be_empty
    end

    context 'when saved' do
      it 'mints ids for a complete record' do
        expect { import.save }
          .to change { import.record_ids.keys }
          .to contain_exactly(upload.file.file.filename)
      end

      context 'when the record is incomplete' do
        let(:ids) { [upload.id] }

        it 'does not mint an id' do
          expect { import.save }
            .not_to change { import.record_ids.keys }
            .from(be_empty)
        end
      end

      it 'skips duplicated filenames' do
        import.save
        same_filename = FactoryBot.create(:hyrax_uploaded_file)
        import.uploaded_file_ids.concat([same_filename.id])

        expect { import.save }.not_to change { import.record_ids }
      end

      context 'with non-matching filenames' do
        let(:ids) { [non_matching_file.id] }
        let(:non_matching_file) do
          FactoryBot
            .create(:hyrax_uploaded_file,
                    file: File.open('spec/fixtures/files/mira_xml.xml'))
        end

        it 'skips non-matching filenames' do
          expect { import.save }
            .not_to change { import.record_ids }
            .from(be_empty)
        end

        it 'cleans up unmatched files' do
          expect { import.save }
            .to change { non_matching_file.class.exists?(non_matching_file.id) }
            .to(false)
        end
      end

      it 'does not assign ids twice' do
        import.save

        expect { import.save }
          .not_to change { import.record_ids[upload.file.file.filename] }
      end
    end
  end
end
