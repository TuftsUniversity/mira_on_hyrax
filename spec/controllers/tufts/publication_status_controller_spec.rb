# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tufts::PublicationStatusController, :workflow, type: :controller do
  let(:work) { FactoryBot.actor_create(:pdf, user: depositing_user) }
  let(:depositing_user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(admin)
  end

  after do
    work.destroy
  end

  describe 'POST #publish' do
    context "publication status" do
      it 'sets the workflow status to published' do
        expect(work.to_sipity_entity.reload.workflow_state_name).to eq "unpublished"
        post :publish, params: { "id" => work.id }
        expect(work.to_sipity_entity.reload.workflow_state_name).to eq "published"
      end
      it 'sets the workflow status to unpublished' do
        post :publish, params: { "id" => work.id }
        expect(work.to_sipity_entity.reload.workflow_state_name).to eq "published"
        post :unpublish, params: { "id" => work.id }
        expect(work.to_sipity_entity.reload.workflow_state_name).to eq "unpublished"
      end
      it "gets the workflow status" do
        expect(work.to_sipity_entity.reload.workflow_state_name).to eq "unpublished"
        post :status, params: { "id" => work.id }
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["status"]).to eq("unpublished")
        post :publish, params: { "id" => work.id }
        expect(work.to_sipity_entity.reload.workflow_state_name).to eq "published"
        post :status, params: { "id" => work.id }
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["status"]).to eq("published")
      end
    end
  end
end
