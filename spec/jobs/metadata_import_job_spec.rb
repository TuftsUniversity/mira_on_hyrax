require 'rails_helper'

RSpec.describe MetadataImportJob, :clean, type: :job do
  subject(:job) { described_class }
  let(:mira_export_ids) { ['sx61dm28w', '37720c723', 'cz30ps66x', 'hh63sv88v', 'k0698748f'] }

  before do
    mira_export_ids.each do |id|
      FactoryBot.create(:pdf, id: id)
    end
  end

  it_behaves_like 'an ActiveJob job'

  describe '#perform' do
    let(:id)      { import.ids.first }
    let(:import)  { FactoryBot.create(:metadata_import) }
    let!(:object) { FactoryBot.create(:populated_pdf, id: id, title: old) }
    let(:old)     { ['Old Title Data'] }

    it 'updates the metadata' do
      expect { job.perform_now(import, id) }
        .to change { object.reload.title }
        .from(old)
        .to contain_exactly('I Married a Electric Ninjas')
    end
  end
end
