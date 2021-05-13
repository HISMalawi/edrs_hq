def remove_redu_states(person_id)
    statuses = RecordStatus.where(person_record_id: person_id).each.sort_by{|s| s.created_at}
    uniqstatus = statuses.collect{|d| d.status}.uniq

    uniqstatus.each do |us|
        redundantstatuses = RecordStatus.(person_record_id:person_id, status: us).each.sort_by{|s| s.created_at}
        #puts us 
        redundantstatuses.each_with_index do |red, i|
                if i != 0
                    begin
                        PersonRecordStatus.find(redundantstatuses[i].id).destroy
                        redundantstatuses[i].destroy
                    rescue
                        puts "Error : #{redundantstatuses[i].id}"
                        puts "Retry"
                        begin
                            PersonRecordStatus.find(redundantstatuses[i].id).destroy
                        rescue
                            puts "Fail"
                        end
                    end
                end
        end
    end

    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"

    PersonRecordStatus.by_person_record_id.key(person_id).each do |s|
        if s.status.blank?
            s.destroy
        end
    end
	
    last = nil
    RecordStatus.where(person_record_id: person_id).order(:created_at).each do |d|
	couch_status = PersonRecordStatus.find(d.person_record_status_id)
	if couch_status.blank?
		d.destroy
	else 
		last = d
	end
    end
    begin
	    last = PersonRecordStatus.find(last.person_record_status_id)
	    last.voided = false
	    last.save
    rescue
	   puts "Error #{person_id}"
    end


end
RecordStatus.where(status:'MARKED HQ APPROVAL', voided:0).each do |d|
	remove_redu_states(d.person_record_id)
	person = Person.find(d.person_record_id)
	if person.drn.blank? || person.drn.includes?('XX')
		PersonIdentifier.assign_drn(person, UserModel.where(username:'datamanager').first.id)
	else
		if person.status.blank? || person.status == 'MARKED HQ APPROVAL'
			PersonRecordStatus.change_status(person,'HQ CAN PRINT')
		end
	end
end