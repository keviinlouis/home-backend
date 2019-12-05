require 'database_cleaner'

DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
