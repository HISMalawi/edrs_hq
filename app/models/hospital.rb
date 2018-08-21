require 'couchrest_model'
require 'thread'

class Hospital < CouchRest::Model::Base

  def hospital_id=(value)
    self['_id']=value.to_s
  end

  def hospital_id
    self['_id']
  end

  property :region, String
  property :district, String
  property :lon, String
  property :lat, String

  timestamps!

  design do
    view :by_updated_at
  end

end