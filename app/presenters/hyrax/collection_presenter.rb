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
    # 
    # Also Addd :total_viewable_items
    def self.terms
      [:total_items, :total_viewable_items, :resource_type, :creator, :contributor, :keyword, :license, :publisher, :date_created, :subject,
       :language, :identifier, :based_near, :related_url]
    end

    # Adding Total items visibile
    # Because Total Items were confusing people
    def [](key)
      case key
      when :size
        size
      when :total_items
        total_items
      when :total_viewable_items
        total_viewable_items
      else
        solr_document.send key
      end
    end
  end
end
