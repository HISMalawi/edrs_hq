connection = ActiveRecord::Base.connection

=begin
sql = "SELECT person_record_id, count(person_record_id) as count 
	   FROM `person_record_status` WHERE status IN('HQ DISPATCHED','HQ PRINTED') 
	   AND voided = 0 GROUP BY person_record_id ORDER BY count DESC LIMIT 50";
=end

#check statuses that have been lost

def correct_status(person)
    if person.status.blank?
        last_status = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|d| d.created_at}.last
        
        states = {
                    "HQ ACTIVE" =>"HQ COMPLETE",
                    "HQ COMPLETE" => "MARKED HQ APPROVAL",
                    "MARKED HQ APPROVAL" => "HQ CAN PRINT",
                    "HQ CAN PRINT" => "HQ PRINTED",
                    "HQ PRINTED" => "HQ DISPATCHED"
                 }
		if last_status.blank?
			if person.first_name.blank? && person.last_name.blank?
				puts person.id
				person.destroy
			else
				PersonRecordStatus.change_status(person, "DC ACTIVE")
			end
	    elsif states[last_status.status].blank?
          PersonRecordStatus.change_status(person, "HQ COMPLETE")
        else  
          PersonRecordStatus.change_status(person, states[last_status.status])
        end
    end	
end

count = Person.count
pagesize = 500
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	Person.all.page(page).per(pagesize).each do |person|
		correct_status(person)
		statuses = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|s| s.created_at}
        uniqstatus = statuses.collect{|d| d.status}.uniq
		uniqstatus.each do |us|
                redundantstatuses = PersonRecordStatus.by_person_record_id_and_status.key([person.id, us]).each.sort_by{|s| s.created_at}
                i = 0
				while i < redundantstatuses.length
						if i != 0
							begin
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
                        i = i + 1
                end
        end
	end

	puts page
	page = page + 1
end


sql = "SELECT person_record_id, count(person_record_id) as id_count FROM person_record_status 
	   WHERE voided = 0 group by person_record_id order by id_count desc limit 1000;"

data = connection.select_all(sql);

def valid_status(statuses)
	last_status = statuses.last
	i = statuses.count - 1
	while i > 0
		if statuses[i]['status'].present?
			last_status = statuses[i]
			break
		else
			last_status = statuses[i]
		end
		i = i - 1
	end
	return last_status
end

data.each do |row|
	 break if row['id_count'].to_i < 2
	

	 statuses = RecordStatus.where(person_record_id: row['person_record_id'] , voided: 0).sort_by { |e| e.created_at }

	 last_status = valid_status(statuses)

	 statuses.each do |d|
	 	next if d['person_record_status_id'] == last_status['person_record_status_id']
	 	s = PersonRecordStatus.find(d['person_record_status_id'])

	 	if s.present?
		 	s.voided = true
	 		s.save
	 		d.voided = 1;
	 		d.save 	
	 	else
	 		d.destroy	 		
	 	end
	 end
	 puts row['person_record_id']
end

=begin
sql ="SELECT person_id FROM people"

data = connection.select_all(sql);
data.each_with_index do |id, index|
	statuses = PersonRecordStatus.by_person_record_id.key(id['person_id']).each.sort_by{|s| s.created_at}
        uniqstatus = statuses.collect{|d| d.status}.uniq

        uniqstatus.each do |us|
                redundantstatuses = PersonRecordStatus.by_person_record_id_and_status.key([id['person_id'], us]).each.sort_by{|s| s.created_at}
                i = 0
                while i < redundantstatuses.length
                        if i != 0
                                redundantstatuses[i].destroy
                        end
                        i = i + 1
                end
        end
	if index % 500 == 0
		puts index
	end
end
=end
