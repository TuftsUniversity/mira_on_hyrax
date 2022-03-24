# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Tufts::TechnicalMetadata do
  subject(:tm) { described_class.new(work) }
  let(:work)   { FactoryBot.create(:pdf) }

  describe 'to_s' do
    it 'returns valid xml' do
      expect(Nokogiri::XML(tm.to_s).errors).to eq([])
    end

    it 'has a technicalMedata root' do
      expect(Nokogiri::XML(tm.to_s).xpath('/technicalMetadata')).not_to eq(nil)
    end
  end

  describe 'to_xml' do
    it 'returns valid xml' do
      expect(Nokogiri::XML(tm.to_xml).errors).to eq([])
    end

    it 'has a technicalMedata root' do
      expect(Nokogiri::XML(tm.to_xml).xpath('/technicalMetadata')).not_to eq(nil)
    end
  end
end
