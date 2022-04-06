# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TemplateUpdateJob, type: :job do
  subject(:job) { described_class }
  let(:item)    { TemplateUpdate::Item.new('behavior', 'id', 'Template') }

  describe '#perform_later' do
    it 'enqueues the job' do
      ActiveJob::Base.queue_adapter = :test

      expect { job.perform_later(*item.values) }
        .to enqueue_job(described_class)
        .with(*item.values)
        .on_queue('batch')
    end
  end
end
