Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URI"], password: ENV["REDIS_PWD"] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URI"], password: ENV["REDIS_PWD"] }
end