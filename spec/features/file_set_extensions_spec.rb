require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Tufts extensions to the FileSet class', :clean do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:work) { FactoryGirl.actor_create(:image, user: admin) }
  let(:fs) { FactoryGirl.create(:file_set, user: admin, title: ['need this for some reason']) }

  scenario 'Set a FileSet to be not downloadable' do
    work.members << fs
    work.save

    login_as admin
    visit edit_hyrax_file_set_path(fs)
    click_link('Permissions')
    page.choose('file_set_downloadable_no-link')
    click_button('update_permission')

    expect(FileSet.find(fs.id).downloadable).to eq('no-link')
  end
end
