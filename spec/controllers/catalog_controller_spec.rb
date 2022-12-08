# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController do
  describe "advance search form" do
    it 'uses "Thesis Type" as a label instead of "Dissertation Type"' do
      config = ::CatalogController.blacklight_config
      expect(config.search_fields["dissertation_type"].label).to eq('Thesis Type')
    end
  end
end
