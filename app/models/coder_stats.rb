class CoderStats < ActiveRecord::Base
    after_commit :push_to_couchDB
    before_create :set_id
    self.table_name = "coder_stats"
    def set_id
		self._id = SecureRandom.uuid if self._id.blank?
	end

    def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if data["type"].nil?
				data["type"] = "CoderStat"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end
end