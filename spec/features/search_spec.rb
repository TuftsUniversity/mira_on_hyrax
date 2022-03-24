# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'perform an advanced search', :clean do
  let(:pdf) { FactoryBot.create(:pdf) }
  let(:another_pdf) { FactoryBot.create(:populated_pdf) }
  let(:user) { FactoryBot.create(:admin) }

  before { login_as user }

  scenario 'performing a basic search to find the first pdf' do
    visit '/dashboard'
    fill_in 'search-field-header', with: pdf.title[0]
    click_on 'Go'
    expect(page).to have_selector('.blacklight-pdf')
    expect(page).to have_content(pdf.title[0])
  end

  scenario 'performing a basic search to find the second pdf' do
    visit '/dashboard'
    fill_in 'search-field-header', with: another_pdf.title[0]
    click_on 'Go'
    expect(page).to have_selector('.blacklight-pdf')
    expect(page).to have_content(another_pdf.title[0])
  end
end
