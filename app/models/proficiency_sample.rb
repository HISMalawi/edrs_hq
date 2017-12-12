require 'couchrest_model'

class ProficiencySample < CouchRest::Model::Base
	property :coder_id, String
	property :sample, []
	property :results, {}
	property :final_result, String
	property :comment, String
	property :supervior,String
	timestamps!
end