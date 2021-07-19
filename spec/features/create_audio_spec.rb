# Generated via
#  `rails generate hyrax:work Audio`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Audio', :clean, js: true do
  context 'a logged in admin user' do
    let(:user) { FactoryGirl.create(:admin) }

    before { login_as user }

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"
      # If you generate more than one work uncomment these lines
      within('form.new-work-select') do
        select 'Audio', from: 'work-type-select-box'
        click_button "Create work"
      end
      expect(page).to have_content "Add New Audio"
      # We want the transcription UI to show up on the form
      expect(page).to have_content('You will need to attach an TEI XML file to to this work to select a transcript.')
    end
  end
end
