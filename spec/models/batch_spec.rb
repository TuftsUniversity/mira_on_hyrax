# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Batch, type: :model, batch: true do
  subject(:batch) { FactoryBot.create(:batch) }

  it { is_expected.to have_attributes(creator: an_instance_of(User)) }
  it { is_expected.to have_attributes(user: an_instance_of(User)) }

  describe '#enqueue' do
    it 'calls enqueue on batchable' do
      allow(batch.batchable).to receive(:enqueue!).and_call_original

      batch.enqueue!
      expect(batch.batchable).to have_received(:enqueue!)
    end
  end

  describe '#job_ids' do
    it { is_expected.to have_attributes(job_ids: be_empty) }

    context 'after it is enqueued' do
      let(:job_hash) { { 'obj1' => 'job1', 'obj2' => 'job2', 'obj3' => 'job3' } }

      before do
        allow(batch.batchable).to receive(:enqueue!).and_return(job_hash)
        batch.enqueue!
      end

      it 'has job ids' do
        expect(batch.job_ids).to contain_exactly(*job_hash.values)
      end

      context 'with no jobs returned' do
        let(:job_hash) { {} }

        it { is_expected.to have_attributes(job_ids: be_empty) }
      end

      context 'when enqueued again with new jobs' do
        let(:new_jobs) { { 'obj4' => 'job4', 'obj5' => 'job5' } }

        before do
          allow(batch.batchable).to receive(:enqueue!).and_return(job_hash, new_jobs)
          batch.enqueue!
        end

        it 'adds the new job ids' do
          expect { batch.enqueue! }
            .to change { batch.job_ids.to_a }
            .to contain_exactly(*(job_hash.values + new_jobs.values))
        end
      end
    end
  end

  describe '#ids' do
    context 'with no ids' do
      subject(:batch) { FactoryBot.build(:batch, ids: nil) }
      it { is_expected.to have_attributes(ids: be_empty) }
    end

    it 'contains item ids' do
      expect(batch.ids).to contain_exactly('abc', '123')
    end
  end

  describe '#items' do
    let(:items) do
      batch.ids.each_with_object({}) { |id, h| h[id] = :"Item #{id}" }
    end

    before do
      items.each do |id, item|
        allow(described_class::Item)
          .to receive(:new)
          .with(id, batch.id, store: described_class::STATUS_STORE)
          .and_return(item)
      end
    end

    it 'contains the items' do
      expect(batch.items).to contain_exactly(*items.values)
    end

    context 'with no ids' do
      subject(:batch) { FactoryBot.build(:batch, ids: nil) }

      it 'is empty' do
        expect(batch.items.first).to be_nil
      end
    end
  end

  describe described_class::Item do
    subject(:batch_item) { described_class.new(batch.ids.first, batch.id) }
    let(:batch)          { FactoryBot.create(:batch, ids: [object.id]) }
    let(:object)         { FactoryBot.create(:generic_object) }
    let(:job_id)         { :FAKE_JOB_ID }

    let(:fake_store) do
      Class.new(Tufts::JobItemStore) do
        def self.fetch(*)
          :FAKE_JOB_ID
        end
      end
    end

    context 'when the object does not exist' do
      it 'can initialize' do
        expect { described_class.new('fake_af_id', batch.id) }.not_to raise_error
      end

      it 'can with initialize with nil' do
        expect { described_class.new(nil, batch.id) }.not_to raise_error
      end
    end

    describe '#job_id' do
      context 'with nothing in the store' do
        it 'is nil' do
          expect(batch_item.job_id).to be_nil
        end
      end

      context 'with a job id in the store' do
        before { batch_item.store = fake_store }

        it 'is the job id' do
          expect(batch_item.job_id).to eq job_id
        end
      end
    end

    describe '#object' do
      it { is_expected.to have_attributes(object: an_instance_of(object.class)) }
    end

    describe '#status' do
      it 'with nothing in the store is unavailable' do
        expect(batch_item.status).to eq :unavailable
      end

      context 'with job in store' do
        before { batch_item.store = fake_store }

        it 'without a status is unavailable' do
          expect(batch_item.status).to eq :unavailable
        end

        it 'has the status' do
          status = :moomin

          allow(ActiveJobStatus).to receive(:get_status).and_return(status)

          expect(batch_item.status).to eq status
        end
      end
    end

    describe '#title' do
      it 'is the title string' do
        expect(batch_item.title).to eq object.title.first
      end

      it 'has a placeholder if there is no title' do
        allow(object).to receive(:title).and_return []

        expect(batch_item.title).to be_a String
      end
    end

    describe '#reviewed?' do
      it 'matches review status of object' do
        expect { batch_item.object.mark_reviewed }
          .to change { batch_item.reviewed? }
          .from(false)
          .to true
      end
    end
  end
end
