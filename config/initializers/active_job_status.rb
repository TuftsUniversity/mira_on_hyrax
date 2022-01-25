r_file = Rails.root.join('config', 'redis.yml').to_s
r_config = YAML::load(File.open(r_file)).deep_symbolize_keys![Rails.env.to_sym]
ActiveJobStatus.store = ActiveSupport::Cache::RedisCacheStore.new(r_config)
