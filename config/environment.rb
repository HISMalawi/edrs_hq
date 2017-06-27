# Load the Rails application.
require File.expand_path('../application', __FILE__)
require "bantu_soundex"
# Initialize the Rails application.
Rails.application.initialize!

require "encryption"
require "sql_search"
require "simple_sql"
