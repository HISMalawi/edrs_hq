class BarcodeRecord < ActiveRecord::Base
	self.table_name = "barcodes"
	def person
		person = Record.find(self.person_record_id)
		person = Person.find(self.person_record_id) if person.blank?
		return person
	end
end