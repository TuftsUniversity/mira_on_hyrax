# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Tei`
module Hyrax
  class TeiForm < Hyrax::Forms::WorkForm
    self.model_class = ::Tei
    self.terms += Tufts::Terms.shared_terms
    Tufts::Terms.remove_terms.each { |term| terms.delete(term) }
    self.required_fields = [:title, :displays_in]
    self.field_metadata_service = Tufts::MetadataService

    def self.model_attributes(_)
      attrs = super
      attrs[:title] = Array(attrs[:title]) if attrs[:title]
      attrs
    end

    # This describes the parameters we are expecting to receive from the client
    # @return [Array] a list of parameters used by sanitize_params
    # This is overriden method review in upgrades, hyrax underlying business logic
    # could potential change out from under it.
    # rubocop:disable  Metrics/MethodLength
    def self.build_permitted_params
      super + [
        :on_behalf_of,
        :version,
        { is_replaced_by: [] },
        { qr_status: [] },
        { rejection_reason: [] },
        { rights_holder: [] },
        { admin_start_date: [] },
        :dissertation_type,
        { tufts_license: [] },
        { date_accepted: [] },
        { date_issued: [] },
        :add_works_to_collection,
        {
          based_near_attributes: [:id, :_destroy],
          member_of_collections_attributes: [:id, :_destroy],
          work_members_attributes: [:id, :_destroy]
        }
      ]
    end

    def title
      super.first || ""
    end
  end
end
