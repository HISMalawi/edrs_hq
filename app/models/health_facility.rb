require 'couchrest_model'

class HealthFacility < CouchRest::Model::Base
  
  def facility_code=(value)
    self['_id']=value.to_s
  end

  def facility_code
    self['_id']
  end

  property :name, String
  property :short_name, String
  property :district,String
  
  timestamps!
  
  design do
      view :by__id
      view :by_name
      view :by_short_name
      view :by_district
  end
  
end
