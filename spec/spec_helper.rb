$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'eyeballs'
require 'database_cleaner'

class Foo < ActiveRecord::Base
  has_many :bars
end
class Bar < ActiveRecord::Base
  belongs_to :foo
end

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      adapter: "postgresql",
      database: ENV["POSTGRES_DB_DATABASE"] || "eyeballs_test",
      username: ENV['POSTGRES_DB_USERNAME'],
      password: ENV['POSTGRES_DB_PASSWORD'],
      host: 'localhost'
    )

    ActiveRecord::Base.connection.execute 'DROP TABLE IF EXISTS bars;'
    ActiveRecord::Base.connection.execute 'DROP TABLE IF EXISTS foos;'

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE TABLE foos (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT
      );
    SQL
    ActiveRecord::Base.connection.execute 'INSERT INTO foos VALUES (1, \'one\')'

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE TABLE bars (
        id INTEGER NOT NULL PRIMARY KEY,
        foo_id INTEGER NOT NULL REFERENCES foos (id),
        name TEXT
      );
    SQL
    ActiveRecord::Base.connection.execute 'INSERT INTO bars VALUES (1,1, \'one\')'

    DatabaseCleaner.strategy = :transaction
  end 

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end 
  end
end

