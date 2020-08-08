states = ["HQ ACTIVE","HQ COMPLETE","MARKED HQ APPROVAL", "HQ CAN PRINT"]
states.each do |status|
	RecordStatus.where(status:status, voided: 0).each do |s|
		statuses = RecordStatus.where(person_record_id: s.person_record_id).order("created_at DESC")
		statuses.each do |d|
			puts s.person_record_id
			next if status == d.status
			begin
				if d.status == "HQ DISPATHED"
					PersonRecordStatus.find(s.person_record_status_id).destroy
					a = PersonRecordStatus.find(s.person_record_status_id)
					a.voided =false
					a.save
					break
				elsif d.status == "HQ PRINTED" || d.status == "DC PRINTED"
					PersonRecordStatus.find(s.person_record_status_id).destroy
					a = PersonRecordStatus.find(s.person_record_status_id)
					a.voided =false
					a.save
					break
				elsif d.status == "HQ CAN PRINT"
					PersonRecordStatus.find(s.person_record_status_id).destroy
					a = PersonRecordStatus.find(s.person_record_status_id)
					a.voided = false
					a.save
					break
				elsif d.status == "MARKED HQ APPROVAL"
					PersonRecordStatus.find(s.person_record_status_id).destroy
					a = PersonRecordStatus.find(s.person_record_status_id)
					a.voided =false
					a.save
					break
				elsif d.status == "HQ COMPLETE"
					PersonRecordStatus.find(s.person_record_status_id).destroy
					a = PersonRecordStatus.find(s.person_record_status_id)
					a.voided =false
					a.save
					break
				else
					next
				end
			rescue
				a = PersonRecordStatus.find(s.person_record_status_id)
				raise  a.inspect if a.present?
			end
		end
	end
end
