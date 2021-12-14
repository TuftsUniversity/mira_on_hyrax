require 'rails_helper'

RSpec.describe Hyrax::XmlImportsController, type: :controller do
  let(:import) { FactoryBot.create(:xml_import) }

  before do
    allow(Collection).to receive(:find).and_return(true)
    import.batch.save
  end

  after { ActiveJobStatus.store.clear }

  context 'as admin' do
    include_context 'as admin'

    describe 'GET #new' do
      it 'renders the form' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      let(:file_upload) { fixture_file_upload('files/mira_xml.xml') }

      it 'uploads the file' do
        post :create, params: { xml_import: { metadata_file: file_upload } }
        expect(assigns(:import).metadata_file.filename).to be_a String
      end

      it 'creates a batch' do
        post :create, params: { xml_import: { metadata_file: file_upload } }
        expect(assigns(:import).batch.creator).to eq user
      end

      context 'when the file has an error' do
        let(:file_upload) { fixture_file_upload('files/mira_xml_invalid.xml') }

        it 'flashes an alert' do
          post :create, params: { xml_import: { metadata_file: file_upload } }
          expect(flash[:alert]).to be_present
        end
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the import' do
      get :edit, params: { id: import.id }

      expect(assigns(:import).xml_import).to eq import
    end
  end

  describe 'GET #show' do
    it 'renders the correct import details' do
      get :show, params: { id: import.id }

      expect(assigns(:import).xml_import).to eq import
    end

    it 'renders the batch' do
      get :show, params: { id: import.id }

      expect(assigns(:import).batch_presenter.object).to eq import.batch
    end
  end

  describe 'PATCH #update' do
    let(:params) { { id: import.id, uploaded_files: file_ids } }

    before { ActiveJob::Base.queue_adapter = :test }

    context 'when files cannot be found' do
      let(:file_ids) { ['38', '91', '1234'] }

      it 'raises an error when files cannot be found' do
        import.uploaded_file_ids = ['1']

        expect { patch :update, params: params }
          .to raise_error { ActiveRecord::RecordInvalid }
      end
    end

    context 'with no files' do
      let(:file_ids) { [] }

      it 'alerts that no files are provided' do
        patch :update, params: params

        expect(flash[:alert]).to be_present
      end
    end

    context 'when files do not match metadata' do
      let(:file_ids) { uploads.map(&:id) }

      let(:uploads) do
        [FactoryBot.create(:hyrax_uploaded_file),
         FactoryBot.create(:hyrax_uploaded_file,
                           file: File.open(file_fixture('3.pdf'))),
         FactoryBot.create(:hyrax_uploaded_file,
                           file: File.open('spec/fixtures/hello.pdf'))]
      end

      it 'enqueues jobs only for matching files' do
        expect { patch :update, params: params }
          .to enqueue_job(ImportJob)
          .with(import, uploads[0..1], an_instance_of(String))
          .exactly(:once)
      end

      it 'updates file ids' do
        expect { patch :update, params: params }
          .to change { import.reload.uploaded_file_ids }
          .to contain_exactly(*file_ids[0..1])
      end

      it 'flashes an alert' do
        patch :update, params: params

        expect(flash[:alert]).to be_present
      end
    end

    context 'when files match metadata' do
      let(:file_ids) { uploads.map(&:id) }

      let(:uploads) do
        [FactoryBot.create(:hyrax_uploaded_file),
         FactoryBot.create(:hyrax_uploaded_file,
                           file: File.open(file_fixture('2.pdf')))]
      end

      it 'enqueues jobs for the matching file' do
        expect { patch :update, params: params }
          .to enqueue_job(ImportJob)
          .exactly(:once)
      end

      it 'updates file ids' do
        expect { patch :update, params: params }
          .to change { import.reload.uploaded_file_ids }
          .to contain_exactly(*file_ids)
      end

      context 'with a new batch' do
        let(:new_file) do
          FactoryBot.create(:hyrax_uploaded_file, file: File.open(file_fixture('3.pdf')))
        end

        it 'adds new jobs to an existing batch' do
          patch :update, params: params

          expect { patch :update, params: { id: import.id, uploaded_files: [new_file.id] } }
            .to change { import.batch.job_ids.count }
            .to 2
        end
      end
    end
  end
end
