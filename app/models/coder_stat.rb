class CoderStat < CouchRest::Model::Base
	property :coder_id, String
	property :random_number, Integer
	property :number_of_records_coded, Integer, :default => 0
	property :sampled, Integer, :default => 0
	property :reviewed, Integer, :default => 0
	design do
		view :by__id
		view :by_coder_id
	end
end