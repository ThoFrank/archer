ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def authenticate_as(user)
      cookie_jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
      user.sessions.create!.tap do |session|
        cookie_jar.signed.permanent[:session_id] = { value: session.id, httponly: true, samesite: :lax }
        cookies[:session_id] = cookie_jar[:session_id]
      end
    end
  end
end

# Usefull for debugging controller tests
# Rails.logger = Logger.new(STDOUT)
# ActiveRecord::Base.logger = Logger.new(STDOUT)
# Rails.logger.level = Logger::DEBUG
