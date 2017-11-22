class ICDCode < CouchRest::Model::Base
	property :code, String
	property :description, String
	timestamps!
	design do
	    view :by_code
	    view :by_description
	end
end