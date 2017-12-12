require 'couchrest_model'

class ProficiencySample < CouchRest::Model::Base
	property :coder_id, String
	property :sample, []
	property :results, {}
	property :final_result, String
	property :comment, String
	property :supervior,String
	property :start_time, Time
	property :end_time, Time
	timestamps!
	design do
    	view :by_end_time
    end
end