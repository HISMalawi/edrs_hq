require "yaml"
require 'mysql2'

class CouchSQL
  include SuckerPunch::Job
  workers 1
  def perform()
   load "#{Rails.root}/bin/script/couch-mysql.rb"
   CouchSQL.perform_in(511)
  end rescue CouchSQL.perform_in(511)
end

