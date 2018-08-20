class ICDCode < CouchRest::Model::Base
	property :code, String
	property :description, String
	property :category, String
	timestamps!
	design do
	    view :by_code
	    view :by_description
	    view :by_code_and_category
	end
end