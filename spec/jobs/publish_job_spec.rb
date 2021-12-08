require 'rails_helper'

RSpec.describe PublishJob, :workflow, type: :job do
  subject(:job) { described_class }
  let(:pdf) { FactoryBot.create(:pdf) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    it 'enqueues the job' do
      expect { job.perform_later(pdf.id) }
        .to enqueue_job(described_class)
        .with(pdf.id)
        .on_queue('batch')
    end
  end

  context "workflow transition" do
    let(:work) { FactoryBot.actor_create(:pdf, user: depositing_user) }
    let(:depositing_user) { FactoryBot.create(:user) }

    it 'sets the workflow status to published' do
      expect(work.to_sipity_entity.reload.workflow_state_name).to eq "unpublished"
      job.perform_now(work.id)
      expect(work.to_sipity_entity.reload.workflow_state_name).to eq "published"
    end
  end
end
