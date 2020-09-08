class Record < ActiveRecord::Base
	self.table_name = "people"
	def drn
		drn_sort_value = RecordIdentifier.by_person_record_id_and_identifier_type.key([self.id, "DEATH REGISTRATION NUMBER"]).first.drn_sort_value rescue nil
		if drn_sort_value.present?
		  drn = "%010d" % drn_sort_value
		  infix = ""
		  if self.gender.match(/^F/i)
			infix = "1"
		  elsif self.gender.match(/^M/i)
			infix = "2"
		  end
		  drn = "#{drn[0, 5]}#{infix}#{drn[5, 9]}"
		  return drn
		else
		  return nil
		end
	end
end
