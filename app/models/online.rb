require 'couchrest_model'

class Online < CouchRest::Model::Base
  property :district_code, String
  property :ip, String
  property :port, String
  property :online, TrueClass, :default => false
  property :time_seen, Time
  
  timestamps!

  design do
      view :by__id
  end

end
