class SampledRecord < ActiveRecord::Base
	before_create :set_id
	self.table_name = "sampled_records"

	def set_id
		self.sampled_record_id = SecureRandom.uuid if self.sampled_record_id.blank?
	end

end