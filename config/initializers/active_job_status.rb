# frozen_string_literal: true

r_file = Rails.root.join('config', 'redis.yml').to_s
template = ERB.new File.read r_file
r_config = YAML.safe_load(template.result).deep_symbolize_keys![Rails.env.to_sym]
ActiveJobStatus.store = ActiveSupport::Cache::RedisCacheStore.new(r_config)
