class PersonICDCode < CouchRest::Model::Base
	property :person_id, String
	property :tentative_code, String
	property :reason_tentative_differ_from_underlying, String
	property :final_code, String
	property :reason_final_differ_from_tentative, String
	property :icd_10_1, String
	property :icd_10_2, String
	property :icd_10_3, String
	property :icd_10_4, String
	property :icd_10_code, String
	timestamps!

	design do
		view :by__id
		view :by_person_id
	end
end