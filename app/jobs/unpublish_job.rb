# frozen_string_literal: true
##
# A job to unpublish an object
class UnpublishJob < BatchableJob
  def perform(id)
    work = ActiveFedora::Base.find(id)
    Tufts::WorkflowStatus.batch_unpublish(work: work, current_user: ::User.batch_user, comment: "Unpublished by UnpublishJob #{Time.zone.now}")
  end
end
