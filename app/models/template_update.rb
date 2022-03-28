# frozen_string_literal: true
##
# A model for managing and tracking template update batches.
#
# @example
#   update = TemplateUpdate.create(template_name: 'blah')
#   update.enqueue
#
# @see Tufts::Template
# @see TemplateUpdateJob
class TemplateUpdate < ApplicationRecord
  # @!attribute batch [rw]
  #   @return [Batch]
  # @!attribute behavior [rw]
  #   @return [String]
  # @!attribute ids [rw]
  #   @return [Array<String>]
  # @!attribute template_name [rw]
  #   @return [String]
  has_one :batch, as: :batchable, inverse_of: :batchable # rubocop:disable Rails/HasManyOrHasOneDependent

  serialize :ids, Array

  OVERWRITE = 'overwrite'
  PRESERVE  = 'preserve'

  TYPE_STRING = 'Template Update'

  ##
  # A struct representing a single item
  #
  # @example
  #   item = Item.new('overwrite', 'abc123', 'My Template')
  #   item.behavior      # => 'overwrite'
  #   item.id            # => 'abc123'
  #   item.template_name # => 'My Template'
  Item = Struct.new(:behavior, :id, :template_name)

  ##
  # @return [String]
  def batch_type
    TYPE_STRING
  end

  ##
  # @return [Hash<String, String>] a hash associating object ids to job ids
  def enqueue!
    jobs_and_objects = items.each_with_object({}) do |item, hsh|
      hsh[item.values[1]] = TemplateUpdateJob.perform_later(*item.values).job_id
    end
    Hyrax::Workflow::BatchTemplateNotification.new(batch, template_name).call
    jobs_and_objects
  end

  ##
  # Configurations for the update of each item in ids.
  #
  # @return [Enumerable<TemplateUpdate::Item>]
  def items
    object_ids.map { |id| Item.new(behavior, id, template_name) }
  end

  ##
  # @return [Array<String>]
  def object_ids
    batch ? batch.ids : []
  end
end
