class OtherSignificantCause < ActiveRecord::Base
	before_create :set_id
	self.table_name = "other_significant_causes"
	def person
		return Record.find(self.person_id)
	end
	def set_id
		self.other_significant_cause_id = SecureRandom.uuid if self.other_significant_cause_id.blank?
	end

end