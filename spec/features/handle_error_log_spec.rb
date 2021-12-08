require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Display Handle errors on the log page', js: true do
  context 'a logged in admin' do
    let(:admin) { FactoryBot.create(:admin) }
    before { login_as admin }
    describe 'viewing the error log as an admin' do
      scenario do
        begin
          handle_registrar = Tufts::HandleRegistrar.new
          handle_registrar.register!(object: Pdf.new)
        rescue; end # rubocop:disable Lint/HandleExceptions
        visit '/handle/log.html'
        expect(page).to have_content 'Unable to register handle'
      end
    end
  end
  context 'a logged in non-admin user' do
    let(:user) { FactoryBot.create(:user) }
    before { login_as user }

    describe 'viewing the error log as a non-admin user' do
      scenario do
        begin
          handle_registrar = Tufts::HandleRegistrar.new
          handle_registrar.register!(object: Pdf.new)
        rescue; end # rubocop:disable Lint/HandleExceptions
        visit '/handle/log.html'
        expect(current_path).to eq "/contribute"
      end
    end
  end
end
