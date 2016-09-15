$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'eyeballs'
require 'database_cleaner'

RSpec.configure do |config|
   require "pry"; binding.pry
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: "postgresql",
      database: ENV["POSTGRES_DB_DATABASE"] || "eyeballs_test",
      username: ENV['POSTGRES_DB_USERNAME'],
      password: ENV['POSTGRES_DB_PASSWORD'],
      host: 'localhost'
    )
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end 

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end 
  end
end

