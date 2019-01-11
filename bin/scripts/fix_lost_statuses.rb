count = Person.count


puts count

pagesize = 200
pages = count / pagesize

page = 1

id = []

while page <= pages
	data = Person.all.page(page).per(pagesize).each
	data.each do |person|
		next if id.include?(person.id)
		
		id << person.id
		record_status = PersonRecordStatus.by_person_recent_status.key(person.id).first
		if record_status.blank?
	        last_status = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|d| d.created_at}.last
	        
	        states = {
	                    "DC ACTIVE" =>"DC COMPLETE",
	                    "DC COMPLETE" => "MARKED APPROVAL",
	                    "MARKED APPROVAL" => "MARKED APPROVAL",
	                    "HQ ACTIVE" =>"HQ COMPLETE",
                    	"HQ COMPLETE" => "MARKED HQ APPROVAL",
                    	"MARKED HQ APPROVAL" =>"MARKED HQ APPROVAL",
                    	"HQ PRINTED" => "HQ DISPATCHED"
	                 }
	        if last_status.blank?
	           PersonRecordStatus.change_status(person, "DC ACTIVE")
	        elsif states[last_status.status].blank?
	          PersonRecordStatus.change_status(person, "DC COMPLETE")
	        else  
	          PersonRecordStatus.change_status(person, states[last_status.status])
	        end	
	        puts "#{person.id} : #{last_status}"
		end
	end
	page = page + 1
end