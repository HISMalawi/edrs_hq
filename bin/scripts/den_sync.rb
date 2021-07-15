def remove_redu_states(person_id)
    #puts person_id
    state = ["DC ACTIVE", "DC COMPLETE","HQ ACTIVE","HQ COMPLETE","MARKED HQ APPROVAL", "HQ CAN PRINT", "HQ PRINTED","HQ DISPATCHED"]
    statuses = PersonRecordStatus.by_person_record_id.key(person_id).each
    statuses.each do |st|
        st.insert_update_into_mysql
    end
    
    uniqstatus = statuses.collect{|d| d.status}.uniq

    uniqstatus.each do |us|
        redundantstatuses = PersonRecordStatus.by_person_record_id.key(person_id).each.reject{|s| s.status != us}.sort_by{|s| s.created_at}

        puts "destroying multiple #{us}"
        redundantstatuses.each_with_index do |red, i|
                if i != 0
                    begin
                        redundantstatuses[i].destroy
                    rescue
                        puts "Error : #{redundantstatuses[i].id}"
                        puts "Retry"
                        begin
                            RecordStatus.find(redundantstatuses[i].id).destroy
                            PersonRecordStatus.find(redundantstatuses[i].id).destroy
                            
                        rescue
                            puts "Fail"
                        end
                    end
                else
                    redundantstatuses[i].insert_update_into_mysql
                end
        end
    end

    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"

    PersonRecordStatus.by_person_record_id.key(person_id).each do |s|
        if s.status.blank?
            s.destroy
        end
    end
	
    last = 0

    RecordStatus.where(person_record_id: person_id).order(:created_at).each do |d|
        person_status = PersonRecordStatus.by_person_recent_status.key(d.person_record_id).last
        if state.find_index(d.status).to_i > last
            last = state.find_index(d.status).to_i
        end

        if person_status.present? && state.find_index(d.status).to_i < state.find_index(person_status.status).to_i
                d.voided = 1 
                d.save
        end
        couch_status = PersonRecordStatus.find(d.person_record_status_id)
        if couch_status.blank?
            d.destroy
        end
    end

    RecordStatus.where(person_record_id: person_id, voided: 0).each do |d|
        if last != state.find_index(d.status).to_i
                couch_status = PersonRecordStatus.find(d.person_record_status_id)
                couch_status.voided = true
                couch_status.save
                d.voided = 1 
                d.save
        else
            couch_status = PersonRecordStatus.find(d.person_record_status_id)
            couch_status.voided = false
            couch_status.save
            d.voided = 0 
            d.save            
        end
    end
    RecordStatus.where(person_record_id: person_id,status: state[last] ).each do |d|
        puts d.status
        couch_status = PersonRecordStatus.find(d.person_record_status_id)
        couch_status.voided = false
        couch_status.save
        d.voided = 0 
        d.save  
    end

end

district =DistrictRecord.all.collect{|d| d.id}
#district = ["LL"]
district.each do |d|
        puts d
        i = 1
        last_den_record = RecordIdentifier.where("district_code ='#{d}' AND identifier LIKE '%2021%'").order("identifier DESC").limit(1).first rescue nil
        if last_den_record.present?
                i = last_den_record.identifier.split("/")[1].to_i rescue 1
        end
        skip = 0
        while  i < 10000

                den ="#{d}/#{i.to_s.rjust(7,"0")}/2021"
                puts den
                identifier = PersonIdentifier.find(den)

                puts "Skip" if identifier.blank?
                skip = skip + 1 if identifier.blank?
                break if skip == 10
                next if identifier.blank?
                identifier.insert_update_into_mysql
                person_record_id = identifier.person_record_id
                person = Person.find(person_record_id)

                person.insert_update_into_mysql
                puts person_record_id
                PersonRecordStatus.by_person_record_id.key(person_record_id).each do |s|
                        puts s.status
                        s.insert_update_into_mysql
                end
                remove_redu_states(person_record_id)
                i = i + 1
        end
end