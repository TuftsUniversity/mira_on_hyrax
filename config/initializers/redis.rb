# frozen_string_literal: true
r_file = Rails.root.join('config', 'redis.yml').to_s
r_config = YAML.safe_load(File.open(r_file)).deep_symbolize_keys![Rails.env.to_sym]
Redis.current = Redis.new(r_config.merge(thread_safe: true))
