# frozen_string_literal: true
namespace :tufts do
  desc "Remove expired embargoes and send notifications. Pass date YYYY-MM-DD. Defaults to today."
  task :embargo_expiration, [:date] => [:environment] do |_t, args|
    Rails.logger.info "Running EmbargoExpirationService"
    EmbargoExpirationService.run(args[:date])
    Rails.logger.info "EmbargoExpirationService Run Complete"
  end
end
