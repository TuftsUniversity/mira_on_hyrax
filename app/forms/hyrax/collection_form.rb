# frozen_string_literal: true
# Override Hyrax::Forms::CollectionForm so we can add Call Number and Finding Aid fields
module Hyrax
  class CollectionForm < Hyrax::Forms::CollectionForm
    self.terms += [:call_number, :finding_aid]

    # Terms that appear above the accordion
    def primary_terms
      [:title, :description, :call_number, :finding_aid]
    end
  end
end
