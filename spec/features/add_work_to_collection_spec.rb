require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Add a work to a collection', :clean, js: true do
  context 'as logged in admin user' do
    let(:admin) { FactoryBot.create(:admin) }
    let(:work) { FactoryBot.actor_create(:image, user: admin, displays_in: ['dl']) }
    let!(:collection) { FactoryBot.create(:collection_lw) }
    let(:title) { FFaker::Book.title }

    before { login_as admin }

    scenario do
      visit('/dashboard/collections/new')
      fill_in 'Title', with: title
      click_button "Save"

      visit("/concern/images/#{work.id}/edit#relationships")
      expect(page).to have_content("This work is currently in these collections")
      find('#s2id_image_member_of_collection_ids').click
      fill_in('s2id_autogen2_search', with: title)
      sleep(1)
      find('.select2-match').click
      find('a[data-behavior="add-relationship"]', match: :first).click
      click_button('Save changes')

      work.reload
      expect(work.member_of_collections).to eq([Collection.where(title: title).first])
      visit("/concern/images/#{work.id}/edit#relationships")
      expect(page).to have_content(title)
    end
  end
end
