require 'couchrest_model'

class ProficiencySample < CouchRest::Model::Base
	property :coder_id, String
	property :sample, []
	property :results, {}
	property :final_result, Integer
	property :reviewed, TrueClass, :default => false
	property :comment, String
	property :supervior,String
	property :start_time, Time
	property :end_time, Time
	timestamps!
	design do
    	view :by_end_time
    	view :by_unreviewed,
    		 :map =>"function(doc){
    		 		if(doc['type'] =='Person' && doc['reviewed'] == false){
    		 			 emit(doc._id, 1);
    		 		}
    		 }"
    end
end