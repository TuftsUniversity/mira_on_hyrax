# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Tei do
  let(:work) { FactoryBot.build(:tei) }
  it_behaves_like 'a work with Tufts metadata attributes'

  it_behaves_like 'a draftable model' do
    subject(:model) { work }

    let(:change_map) do
      { title: ['Another title'], displays_in: ['tarc'], subject: ['Testing'] }
    end
  end

  it { expect(described_class.human_readable_type).to eq 'TEI' }
end
