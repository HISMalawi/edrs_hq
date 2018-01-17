PersonRecordStatus.all.each do |status|
		record_status = status
		status.voided = 1 
		status.save
end

Person.all.each do |person| 
	PersonRecordStatus.create({
	                                  :person_record_id => person.id,
	                                  :status => "HQ COMPLETE",
	                                  :district_code =>person.district_code,
	                                  :creator =>person.created_by})
end