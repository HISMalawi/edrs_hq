require 'couchrest_model'

class ProficiencySample < CouchRest::Model::Base
	property :coder_id, String
	property :sample, []
	property :results, {}
	property :final_result, String
	property :reviewed, []
	property :comment, String
	property :supervisor,String
	property :date_sampled, Date
	property :start_time, Time
	property :end_time, Time
	timestamps!
	design do
    	view :by_end_time
    	view :by_coder_id
    	view :by_created_at
    	view :by_result,
    		 :map => "function(){
    		 				if(doc['type']=='ProficiencySample' && doc['final_result'] >= 0){
    		 					 emit([doc._id, doc['final_result']], 1);
    		 				}
    		 		 }"
    end
end