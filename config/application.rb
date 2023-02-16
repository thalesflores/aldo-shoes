# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AldoShoes
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    Dotenv::Railtie.load if %w[development test].include? ENV['RAILS_ENV']
    config.api_only = true

    config.after_initialize do
      include InventoryService
      InventoryService.connect
    end
  end
end
