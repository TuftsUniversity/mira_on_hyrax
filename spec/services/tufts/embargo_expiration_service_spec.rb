# frozen_string_literal: true
require 'rails_helper'

describe Tufts::EmbargoExpirationService, :workflow, :clean do
  let(:record) { FactoryBot.create(:embargoed_work_with_files) }
  let(:service) { described_class.new(DateTime.now) }

  before do
    record.embargo_release_date = record.embargo_release_date - 365
    allow(service).to receive(:find_expirations).and_return([record])
  end

  it 'expire_embargoes change visbility to public' do
    expect(record.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

    service.expire_embargoes

    expect(record.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  it 'expire_embargoes change associated files visbility to public' do
    expect(record.file_sets.first.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

    service.expire_embargoes

    expect(record.file_sets.first.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
