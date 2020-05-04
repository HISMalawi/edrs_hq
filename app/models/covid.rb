require 'couchrest_model'

class Covid < CouchRest::Model::Base
	after_save :insert_update_into_mysql

  	property :person_record_id, String
  	property :test_result, String
  	property :comment, String
  	property :other_data, {}
  
  	timestamps!

	design do
	      view :by__id
	      view :by_person_record_id
	end

	def insert_update_into_mysql
	    fields  = self.keys.sort
	    sql_record = CovidRecord.where(person_covid_record_id: self.id).first
	    sql_record = CovidRecord.new if sql_record.blank?
	    fields.each do |field|
	      next if field == "type"
	      next if field == "_rev"
	      if field =="_id"
	          sql_record["person_covid_record_id"] = self[field]
	      elsif field =="other_data"
	    	  sql_record["other_data"] = self[field].as_json
	      else
	          sql_record[field] = self[field]
	      end
		end
		begin
			sql_record.save
		rescue 
		end
	end

	def delete_from_mysql
		sql_record = CovidRecord.where(person_covid_record_id: self.id).first
		if sql_record.present?
			sql_record.destroy
		end
	end
end
