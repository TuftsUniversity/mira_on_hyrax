# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'redirection' do
  let(:pdf) { FactoryBot.create(:pdf) }

  context 'a unauthenticated visitor' do
    describe 'getting redirected to contribute when logging in' do
      scenario do
        visit '/dashboard'
        expect(page).to have_content 'Login'
      end
    end

    describe 'getting redirected when you enter a bad path' do
      scenario do
        visit '/this/is/a/bad/path'
        expect(page).to have_content 'Login'
      end
    end

    describe 'getting redirected when you go to an item page' do
      scenario do
        visit "/concern/pdfs/#{pdf.id}"
        expect(page).to have_content 'Login'
      end
    end
  end

  context 'an authenticated user (non-admin user)' do
    let(:user) { FactoryBot.create(:user) }
    before { login_as user }

    describe 'getting redirected to contribute when logging in' do
      scenario do
        visit '/dashboard'
        expect(page).to have_selector '#deposit_type'
      end
    end

    describe 'getting redirected when you enter a bad path' do
      scenario do
        visit '/this/is/a/bad/path'
        expect(page).to have_selector '#deposit_type'
      end
    end

    describe 'getting redirected when you go to an item page' do
      scenario do
        visit "/concern/pdfs/#{pdf.id}"
        expect(page).to have_current_path('/contribute?locale=en')
        expect(page).to have_selector '#deposit_type'
      end
    end
  end

  context 'an admin user' do
    let(:user) { FactoryBot.create(:admin) }
    before { login_as user }

    describe 'being able to access the dashboard' do
      scenario do
        visit '/dashboard'
        expect(page).to have_content 'Manage'
      end
    end

    describe 'getting redirected to the dashboard when visiting root' do
      scenario do
        visit '/'
        expect(page).to have_content 'Dashboard'
      end
    end

    describe 'having access to search when on dashboard' do
      scenario do
        visit '/dashboard'
        expect(page).to have_selector '#search-field-header'
      end
    end

    describe 'getting redirected when you enter a bad path' do
      scenario do
        visit '/this/is/a/bad/path'
        expect(page).to have_selector '#deposit_type'
      end
    end

    describe 'viewing an item page' do
      scenario do
        visit "/concern/pdfs/#{pdf.id}"
        expect(page).to have_content pdf.title[0]
      end
    end
  end
end
