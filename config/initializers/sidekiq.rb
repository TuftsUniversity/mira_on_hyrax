# frozen_string_literal: true
require 'sidekiq-limit_fetch'
require 'sidekiq/web'
auth = if Rails.application.config_for(:redis)["password"]
         ":" + Rails.application.config_for(:redis)["password"] + "@"
       else
         ""
       end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://' + auth + 'localhost:6379' }
  config.failures_max_count = 5000
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://' + auth + 'localhost:6379' }
end

Sidekiq::Web.app_url = '/dashboard'
