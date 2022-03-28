# frozen_string_literal: true
class BatchableJob < ApplicationJob
  include ActiveJobStatus::Hooks

  queue_as :batch
end
