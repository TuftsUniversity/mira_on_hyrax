# frozen_string_literal: true
# Generated via
require 'rails_helper'
require 'ffaker'
require 'byebug'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Collection', :clean, js: true do
  context 'a logged in admin user' do
    let(:user) { FactoryBot.create(:admin) }
    let(:title) { FFaker::Book.title }
    let(:call_number) { 'fake_call_number' }
    let(:finding_aid) { 'fake_finding_aid' }
    let!(:user_collection_type) { create(:user_collection_type) }

    before { login_as user }

    scenario do
      visit '/dashboard'
      click_link "Collections"
      sleep(2)
      click_link "New Collection"

      # Call Number and Finding Aid are form entry field when you create a new Collection
      fill_in 'Title', with: title
      fill_in 'Call Number', with: call_number
      fill_in 'Finding Aid', with: finding_aid
      click_button "Save"
      click_link "Cancel"

      # Call Number and Finding Aid are displayed on the Collection page within the admin dashboard
      expect(page).to have_content "Call Number"
      expect(page).to have_content call_number
      expect(page).to have_content "Finding Aid"
      expect(page).to have_content finding_aid

      # Call Number and Finding Aid are displayed on the Collection page outside the admin dashboard
      c = Collection.last
      visit "/collections/#{c.id}"
      expect(page).to have_content "Call Number"
      expect(page).to have_content call_number
      expect(page).to have_content "Finding Aid"
      expect(page).to have_content finding_aid
    end
  end
end
