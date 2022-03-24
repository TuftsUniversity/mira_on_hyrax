# frozen_string_literal: true
require 'rails_helper'

describe Tufts::HandleLogController do
  context "as an admin" do
    before do
      sign_in FactoryBot.create(:admin)
      # Ensure a log file exists
      FileUtils.touch Tufts::HandleLogService.instance.filename
    end
    it "returns html" do
      get :index
      expect(response).to be_successful
    end

    it "returns text" do
      get :index, format: :txt
      expect(response.body).to eq File.read(Tufts::HandleLogService.instance.filename)
    end
  end

  context 'a non-admin' do
    it "redirects" do
      get :index
      expect(flash[:alert]).to eq 'You are not authorized to access this page.'
    end
  end
end
