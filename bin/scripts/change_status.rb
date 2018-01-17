Person.all.each do |person| 
	record_status = nil
	PersonRecordStatus.by_person_record_id.key(person.id).each do |status|
		record_status = status
		status.voided = 1 
		status.save
	end
	PersonRecordStatus.create({
	                                  :person_record_id => record_status.person_record_id.to_s,
	                                  :status => "HQ COMPLETE",
	                                  :district_code => record_status.district_code,
	                                  :creator =>record_status.creator})
end