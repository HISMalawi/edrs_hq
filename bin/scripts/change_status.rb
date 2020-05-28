
#rails r bin/scripts/change_status.rb '/home/emmanuel/to_print.txt' 'HQ CAN PRINT'
#rails r bin/scripts/change_status.rb '/home/emmanuel/to_hq_active.txt' 'HQ ACTIVE'
def write_csv_header(file, header)
    CSV.open(file, 'w' ) do |exporter|
        exporter << header
    end
end

def write_csv_content(file, content)
    CSV.open(file, 'a+' ) do |exporter|
        exporter << content
    end
end

file_name = "#{Rails.root}/db/status.csv"

write_csv_header(file_name, ["ID","DEN","Status Trail"])

status = ARGV[1]
file_path = ARGV[0]
file = File.open(file_path)
file_data = file.readlines.map(&:chomp)

file_data.each do |den|
	identifier_record = PersonIdentifier.by_identifier.key(den).first
	next if identifier_record.blank?

	record_status = PersonRecordStatus.by_person_recent_status.key(identifier_record.person_record_id).first
	if record_status.blank?
		
	end
	statuses = PersonRecordStatus.by_person_record_id.key(identifier_record.person_record_id).each.sort_by{|s| s.created_at}

	uniqstatus = statuses.collect{|d| d.status}.uniq

	uniqstatus.each do |us|
		redundantstatuses = PersonRecordStatus.by_person_record_id_and_status.key([identifier_record.person_record_id, us]).each.sort_by{|s| s.created_at}
		i = 0
		while i < redundantstatuses.length
			if i != 0
				redundantstatuses[i].destroy
			end	
			i = i + 1	
		end
	end


	person = identifier_record.person

	if uniqstatus.include?("HQ DISPATCHED")
		#PersonRecordStatus.change_status(person,"HQ DISPATCHED")
		state = PersonRecordStatus.by_person_record_id_and_status.key([identifier_record.person_record_id, "HQ DISPATCHED"]).last
		state.voided = false
		state.save
	elsif uniqstatus.include?("HQ PRINTED")
		state = PersonRecordStatus.by_person_record_id_and_status.key([identifier_record.person_record_id, "HQ PRINTED"]).last
		state.voided = false
		state.save
	elsif uniqstatus.include?("DC PRINTED")
		state = PersonRecordStatus.by_person_record_id_and_status.key([identifier_record.person_record_id, "DC PRINTED"]).last
		state.voided = false
		state.save
	else
		if uniqstatus.last == status
			state = PersonRecordStatus.by_person_record_id_and_status.key([identifier_record.person_record_id, status]).last
			state.voided = false
			state.save	
		else
			PersonRecordStatus.change_status(person,status)	
		end	
	end
	puts den
	statuses = PersonRecordStatus.by_person_record_id.key(identifier_record.person_record_id).each.sort_by{|s| s.created_at}
	write_csv_content(file_name, [identifier_record.person_record_id,den, statuses.collect{|d| d.status}])
end
puts file_data.length
puts status