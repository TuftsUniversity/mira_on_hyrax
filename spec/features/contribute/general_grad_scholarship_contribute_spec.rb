# frozen_string_literal: true
require 'rails_helper'
require 'ffaker'
require 'import_export/deposit_type_importer.rb'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'General Graduate Scholarship', :clean, js: true do
  # TODO: make a csv file
  let(:csv_path) { Rails.root.join('config', 'deposit_type_seed.csv').to_s }
  let(:importer) { DepositTypeImporter.new(csv_path) }
  let(:pdf_path) { Rails.root.join('spec', 'fixtures', 'hello.pdf') }
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:title) { FFaker::Movie.unique.title }
  let(:advisory) { "advisory" }
  let(:short_description) { FFaker::Book.description }

  before do
    allow(CharacterizeJob).to receive(:perform_later).and_return(true) # Don't run fits
    login_as user
    # loads the deposit_types
    importer.import_from_csv
  end

  scenario do
    visit '/contribute'
    select 'General Graduate Scholarship', from: 'deposit_type'
    click_button 'Begin'
    attach_file('PDF to upload', pdf_path)
    fill_in 'Title', with: title
    fill_in 'Short Description', with: short_description

    # Test department autocomplete
    fill_in 'Department', with: 'geol'
    page.execute_script %{ $('#contribution_department').trigger('focus') }
    page.execute_script %{ $('#contribution_department').trigger('keydown') }
    expect(page).to have_selector('ul.ui-autocomplete li.ui-menu-item')
    page.execute_script %{ $('ul.ui-autocomplete li.ui-menu-item:contains("Dept. of Geology")').trigger('mouseenter').click() }
    expect(find_field('Department').value).to eq 'Dept. of Geology'

    fill_in 'Advisor', with: advisory

    click_button 'Agree & Deposit'
    expect(page).to have_content 'Your deposit has been submitted for approval.'
  end
end
