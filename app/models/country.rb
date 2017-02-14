class Country < CouchRest::Model::Base
	property :name, String
	property :iso, String
	property :numcode, String
	property :phonecode, String
	design do
	    view :by__id
	    view :by_nationality
	end
end
