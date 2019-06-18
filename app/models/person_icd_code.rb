class PersonICDCode < CouchRest::Model::Base
	after_save :insert_update_into_mysql
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

	property :review_results

	property :other_significant_causes, {}
	timestamps!

	design do
		view :by__id
		view :by_person_id
	end

	def insert_update_into_mysql
	    fields  = self.keys.sort
	    sql_record = RecordICDCode.where(person_icd_code_id: self.id).first
	    sql_record = RecordICDCode.new if sql_record.blank?
	    fields.each do |field|
	      next if field == "type"
	      next if field == "_rev"
	      next if field == "source_id"
	      if field =="_id"
	          sql_record["person_icd_code_id"] = self[field]
	      else
	          sql_record[field] = self[field]
	      end

	    end
	    sql_record.save
	end
end