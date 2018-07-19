class PersonICDCode < CouchRest::Model::Base
	property :person_id, String

	property :tentative_code, String
	property :reason_tentative_differ_from_underlying, String

	property :final_code, String
	property :reason_final_differ_from_tentative, String

	property :icd_10_1_reviewed, String
	property :reason_icd_10_1_changed, String

	property :icd_10_2_reviewed, String
	property :reason_icd_10_2_changed, String

	property :icd_10_3_reviewed, String
	property :reason_icd_10_3_changed, String

	property :icd_10_4_reviewed, String
	property :reason_icd_10_4_changed, String

	property :tentative_code_reviewed, String
	property :reason_tentative_code_changed, String

	property :final_code_reviewed, String
	property :reason_final_code_changed, String

	property :other_significant_causes, {}
	timestamps!

	design do
		view :by__id
		view :by_person_id
	end
end