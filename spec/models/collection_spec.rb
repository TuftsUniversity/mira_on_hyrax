# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Collection, type: :model do
  subject(:collection) { FactoryBot.build(:collection_lw) }

  it_behaves_like 'a record with ordered fields' do
    let(:work) { collection }
  end

  it "has an associated call_number and finding_aid" do
    expect(collection.call_number.first).to start_with "Call Number"
    expect(collection.finding_aid.first).to start_with "Finding Aid"
  end
end
