require "pry"

# Load the library
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "inquiry"

# Initialize DB connection
require "sqlite3"
require "yaml"
db_config = YAML::load(File.open("db/config.yml")).fetch("test")
ActiveRecord::Base.establish_connection(db_config)

# Load spec support files
Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].each {|f| require f }

# Clean the database every run
require "database_cleaner"
RSpec.configure do |config|
  config.include Inquiry::SpecUtilities
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
