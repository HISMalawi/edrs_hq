class ProficiencySampleRecord < ActiveRecord::Base
    self.table_name = "proficiency_sample"
    after_commit :push_to_couchDB
    before_create :set_id
    def set_id
		self.proficiency_sample_id = SecureRandom.uuid if self.proficiency_sample_id.blank?
	end

    def self.created_or_update_sample(params)
        sample = ProficiencySampleRecord.where(coder_id: params[:coder_id]).first
        
        if sample.blank?
            sample = ProficiencySampleRecord.new 
            sample.coder_id = params[:coder_id]
			sample.save
        end

        couchdb_sample_record = ProficiencySample.find(sample.id)

        SampledRecord.create({
			:proficiency_sample_id => sample.id,
			:person_record_id => params[:person_record_id],
			:reviewed => 0,
			:created_at => Time.now,
			:updated_at => Time.now
		})

		ids = couchdb_sample_record.sample rescue []
		ids << params[:person_record_id] unless ids.include?(params[:person_record_id)

		couchdb_sample_record.sample = ids
		couchdb_sample_record.save
    end

	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "proficiency_sample_id"
			 	data["_id"] = self.as_json[key]
			elsif key=="voided"
				data[key] = (self.as_json[key]==1? true : false)
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "ProficiencySample"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end
end