# frozen_string_literal: true
require_dependency Hyrax::Engine.root.join('app', 'presenters', 'hyrax', 'collection_presenter').to_s

module Hyrax
  class CollectionPresenter
    # Terms is the list of fields displayed by
    # app/views/collections/_show_descriptions.html.erb
    #
    # PATCH: (can be removed in 4.0, or possibly earlier)
    # Removed :size from the list because it just displays
    # 'unknown' on the interface and is to be removed in 4.0.
    def self.terms
      [:total_items, :resource_type, :creator, :contributor, :keyword, :license, :publisher, :date_created, :subject,
       :language, :identifier, :based_near, :related_url]
    end
  end
end
