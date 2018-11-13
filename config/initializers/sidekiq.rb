require 'sidekiq-limit_fetch'

auth = if Rails.application.config_for(:redis)["password"]
         ":" + Rails.application.config_for(:redis)["password"] + "@"
       else
         ""
       end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://' + auth + 'localhost:6379' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://' + auth + 'localhost:6379' }
end