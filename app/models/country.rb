class Country < CouchRest::Model::Base
	property :name, String
	property :iso, String
	property :numcode, String
	property :phonecode, String
	timestamps!
	design do
	    view :by__id
	    view :by_name
	    view :by_updated_at
	end
end
