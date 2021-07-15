class PersonICDCodes < ActiveRecord::Base
    self.table_name = "person_icd_codes"
    after_commit :push_to_couchDB
    before_create :set_id
    def set_id
		self.person_icd_code_id = SecureRandom.uuid if self.person_icd_code_id.blank?
	end
	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "person_icd_code_id"
			 	data["_id"] = self.as_json[key]
			elsif key=="voided"
				data[key] = (self.as_json[key]==1? true : false)
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "PersonICDCode"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end
end