PersonRecordStatus.all.each do |status|
	status.voided = 1 
	if status.save
		        PersonRecordStatus.create({
                                  :person_record_id => status.person_status_id.to_s,
                                  :status => "HQ COMPLETE",
                                  :district_code => status.district_code,
                                  :creator => status.creator})
	end
end