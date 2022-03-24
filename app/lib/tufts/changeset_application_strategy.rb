# frozen_string_literal: true
module Tufts
  ##
  # @abstract Concrete implementions require an `#apply` method.
  #
  # @example Applying a changeset
  #   strategy = ChangesetApplicationStrategy.new(model:     model,
  #                                               changeset: changeset)
  #   strategy.apply
  #
  # @example Using the factory method
  #   ChangesetApplicationStrategy.for(:preserve, model: model)
  #   # => #[ChangesetPreserveStrategy...]
  #
  class ChangesetApplicationStrategy
    class << self
      ##
      # @param name      [#to_sym]
      # @param changeset [ActiveFedora::Changeset]
      # @param model     [ActiveFedora::Base]
      #
      # @return [ChangesetApplicationStrategy] a strategy built from the symbol
      def for(name, changeset: nil, model:)
        opts = {}
        opts[:changeset] = changeset if changeset
        opts[:model]     = model

        (@registry[name.to_sym] || ChangesetApplicationStrategy).new(**opts)
      end

      ##
      # @param name  [#to_sym]
      # @param klass [Class]
      #
      # @return [void]
      def register(name, klass)
        @registry ||= {}
        @registry[name.to_sym] = klass
      end
    end

    ##
    # @!attribute changeset [rw]
    #   @return [ActiveFedora::Changeset]
    # @!attribute model [rw]
    #   @return [ActiveFedora::Base]
    attr_accessor :changeset, :model

    ##
    # @param changeset [ActiveFedora::ChangeSet]
    # @param model     [ActiveFedora::Base]
    def initialize(changeset: NullChangeSet.new, model:)
      @changeset = changeset
      @model     = model
    end

    ##
    # @abstract
    # @return [void] applies the changeset to the model
    #
    # @raise [ApplicationError] when the changeset is invalid for the model
    # @raise [NotImplementedError] if this is an abstract strategy
    def apply
      raise NotImplementedError, "#{self.class} does not implement `#apply`; " \
                                 'Should this be a concrete ' \
                                 'ChangesetApplicationStrategy'
    end

    ##
    # An error class for errors occurring during application of the chnageset
    class ApplicationError < RuntimeError; end
  end

  require 'tufts/changeset_overwrite_strategy'
  require 'tufts/changeset_preserve_strategy'
end
