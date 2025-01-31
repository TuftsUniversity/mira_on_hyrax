# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work VotingRecord`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a VotingRecord', :clean, js: true do
  context 'a logged in admin user' do
    let(:user) { FactoryBot.create(:admin) }

    before { login_as user }

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"
      # If you generate more than one work uncomment these lines
      within('form.new-work-select') do
        select 'Voting Record', from: 'work-type-select-box'
        click_button "Create work"
      end
      expect(page).to have_content "Add New Voting Record"
    end
  end
end
