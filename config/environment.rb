# Load the Rails application.
require File.expand_path('../application', __FILE__)
require "bantu_soundex"
# Initialize the Rails application.
Rails.application.initialize!

require "encryption"
require "simple_sql"
require "simple_elastic_search"
require "couchdb_to_mysql"
require "person_service"