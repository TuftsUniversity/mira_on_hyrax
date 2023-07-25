# frozen_string_literal: true
require 'byebug'

module Tufts
  ##
  # A record for import.
  #
  # Instances are in-memory representations of records from import
  # documents, prepared for import into Fedora. In addition to the metadata
  # present in the final record, several other pieces of data are provided
  # to the import record to aid in importing the correct files and types.
  #
  # @example
  #   record      = ImportRecord.new
  #   record.file = 'filename.png'
  #
  # @todo This class has gotten quite large. A refactor may be beneficial.
  # rubocop:disable Metrics/ClassLength
  class ImportRecord
    include Tufts::Normalizer

    VISIBILITY_VALUES =
      [Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO,
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE,
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE].freeze

    THUMBNAIL_VALUE      = 'thumbnail'
    TRANSCRIPT_VALUE     = 'transcript'
    REPRESENTATIVE_VALUE = 'representative'

    ##
    # @!attribute mapping [rw]
    #   @return [MiraXmlMapping]
    # @!attribute metadata [rw]
    #   @return [Nokogiri::XML::Node, nil]
    # @!attribute file [rw]
    #   @return [String]
    attr_accessor :mapping, :metadata
    attr_writer   :file

    ##
    # @param metadata [Nokogiri::XML::Node, nil]
    def initialize(metadata: nil, mapping: MiraXmlMapping.new)
      @mapping  = mapping
      @metadata = metadata
    end

    ##
    # @return [String, nil]
    def id
      return nil if metadata.nil?

      metadata.xpath('./tufts:id', mapping.namespaces)
              .children.map(&:content).first
    end

    ##
    # @return [Class] The model given by model:hasModel; GenericObject if none.
    def object_class
      return GenericObject if metadata.nil?

      name = metadata.xpath('./model:hasModel', mapping.namespaces).children.first

      name ? name.content.constantize : GenericObject
    end

    ##
    # @return [String]
    def file
      return '' if files.empty?
      files.first
    end

    ##
    # @return [String]
    def thumbnail
      file_by_type(THUMBNAIL_VALUE)
    end

    ##
    # @return [String]
    def transcript
      file_by_type(TRANSCRIPT_VALUE)
    end

    ##
    # @return [String]
    def representative
      file_by_type(REPRESENTATIVE_VALUE)
    end

    ##
    # @return [Array<String>]
    def files
      return [] if metadata.nil?
      metadata.xpath('./tufts:filename', mapping.namespaces).children.map(&:content)
    end

    ##
    # @return [String]
    def title
      return file if metadata.nil?

      @title ||=
        metadata.xpath('./dc:title', mapping.namespaces)
                .children.map(&:content).first || file
    end

    def visibility_during_embargo
      return nil if metadata.nil?
      visibility_during_embargo = metadata.xpath('./tufts:visibility_during_embargo', mapping.namespaces).children.map(&:content).first

      return visibility_during_embargo unless visibility_during_embargo.nil?
      return nil if visibility_during_embargo.nil? && embargo_release_date.nil?

      # Default to private
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    def visibility_after_embargo
      return nil if metadata.nil?

      visibility_after_embargo = metadata.xpath('./tufts:visibility_after_embargo', mapping.namespaces).children.map(&:content).first
      return visibility_after_embargo unless visibility_after_embargo.nil?
      return nil if visibility_after_embargo.nil? && embargo_release_date.nil?

      # Should default to inputed visibility
      visibility = metadata.xpath('./tufts:visibility', mapping.namespaces).first.content
      return visibility unless visibility.nil?

      # If no info to go off of default public
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    def embargo_release_date
      return nil if metadata.nil?
      metadata.xpath('./tufts:embargo_release_date', mapping.namespaces).children.map(&:content).first
    end

    ##
    # @return [Array<String>]
    def collections
      return [] if metadata.nil?
      metadata.xpath('./tufts:memberOf', mapping.namespaces).children.map(&:content)
    end

    ##
    # @return [ActiveFedora::Core] a tufts model
    def build_object(id: self.id)
      attributes = fields.each_with_object({}) do |field, attrs|
        attrs[field.first] = field.last
      end

      # set additional attributes
      if embargo_release_date
        attributes[:visibility_during_embargo] = visibility_during_embargo
        attributes[:visibility_after_embargo] = visibility_after_embargo
        attributes[:embargo_release_date] = embargo_release_date
      else
        attributes[:visibility] = visibility
      end

      attributes[:member_of_collections] = ActiveFedora::Base.find(collections)

      return object_class.new(**attributes) unless id

      begin
        object = object_class.find(id)
        object.assign_attributes(attributes)
        object
      rescue ActiveFedora::ObjectNotFoundError
        object_class.new(id: id, **attributes)
      end
    end

    def fields
      return [].to_enum        unless metadata
      return enum_for(:fields) unless block_given?
      mapping.map do |field|
        case field.property
        when :title
          yield [:title, Array.wrap(title)]
        when :date_modified
          yield [:date_modified, Time.current]
        when :id, :has_model, :date_uploaded, :create_date, :modified_date, :head, :tail
          next
        else
          values = values_for(field: field)
          yield [field.property, values]
        end
      end
    end

    ##
    # @return [String]
    def visibility
      default = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

      return default if metadata.nil?

      visibilities = metadata.xpath('./tufts:visibility', mapping.namespaces)

      return default if visibilities.empty?

      visibility_text = visibilities.first.content
      return visibility_text if VISIBILITY_VALUES.include?(visibility_text)

      raise VisibilityError
    end

    class VisibilityError < ArgumentError; end

    private

    def file_by_type(type)
      return '' if metadata.nil?

      file_node =
        metadata
        .xpath("./tufts:filename[@type=\"#{type}\"]", mapping.namespaces)
        .first

      file_node.try(:content) || ''
    end

    def singular_properties
      @singular_properties =
        GenericObject
        .properties.select { |_, cf| cf.try(:multiple?) == false }
        .keys.map(&:to_sym)
    end

    def sanitize_import_field(values)
      if values
        if values.is_a?(Array)
          ary = []
          values.each do |v|
            ary << Tufts::InputSanitizer.sanitize(v)
          end

          values = ary
        else
          values = Tufts::InputSanitizer.sanitize(values.to_s)
        end
      end
      values
    end

    def values_for(field:)
      values =
        metadata
        .xpath("./#{field.namespace}:#{field.name}", @mapping.namespaces)
        .children
      return nil if values.empty?

      values = values.map(&:content)
      values = values.first if singular_properties.include?(field.property)
      values = normalize_import_field(field, values)
      values = sanitize_import_field(values)
      values
    end
  end
  # rubocop:enable Metrics/ClassLength
end
