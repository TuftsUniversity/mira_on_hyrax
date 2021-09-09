require 'rails_helper'
require 'import_export/deposit_type_importer'

RSpec.feature 'DepositType seed' do
  let(:deposit_types) { CSV.read('./config/deposit_type_seed.csv', headers: true) }
  let(:known_display_name) { deposit_types.first.field("display_name") }

  before(:all) do
    importer = DepositTypeImporter.new('./config/deposit_type_seed.csv')
    importer.import_from_csv
  end

  it 'gets loaded' do
    expect(DepositType.count).to be > 0
  end

  it "populates expected data" do
    matching_records = DepositType.where(display_name: known_display_name)
    expect(matching_records).not_to be_empty
  end
end
