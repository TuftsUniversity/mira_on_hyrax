# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ImportJob, type: :job do
  subject(:job) { described_class }

  let(:file)   { FactoryBot.create(:hyrax_uploaded_file) }
  let(:import) { FactoryBot.create(:xml_import, uploaded_file_ids: [file.id]) }
  let(:pdf)    { FactoryBot.create(:pdf) }

  before do
    allow(Collection).to receive(:find).and_return(true)
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      ActiveJob::Base.queue_adapter = :test
      expect { job.perform_later(import, [file], pdf.id) }
        .to enqueue_job(described_class)
        .with(import, [file], pdf.id)
        .on_queue('batch')
    end
  end
end
