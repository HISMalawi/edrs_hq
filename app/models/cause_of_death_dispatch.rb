class CauseOfDeathDispatch < CouchRest::Model::Base
	property :dispatch,[]
	property :received,[]
	property :reviewed, TrueClass, :default => false
	property :district_code, String
	property :creator, String
	timestamps!

	design do
    	view :by__id
    	view :by_creator
    	view :by_reviewed
    	view :by_district_code
    	view :by_created_at
		filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
    end

end