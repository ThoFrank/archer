require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Archer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # sprockets
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app", "assets")
    config.assets.precompile += %w( application.js application.css )

    initializer 'sprockets.environment', before: :load_config_initializers do |app|
      app.config.assets.configure do |env|
        env.cache = ActiveSupport::Cache.lookup_store(:memory_store)
      end
    end


  end
end
