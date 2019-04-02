connection = ActiveRecord::Base.connection

=begin
sql = "SELECT person_record_id, count(person_record_id) as count 
	   FROM `person_record_status` WHERE status IN('HQ DISPATCHED','HQ PRINTED') 
	   AND voided = 0 GROUP BY person_record_id ORDER BY count DESC LIMIT 50";
=end

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

=begin
	 statuses = PersonRecordStatus.by_person_record_id.key(row['person_record_id']).each.sort_by{|s| s.created_at}
	 status_to_skip = statuses.last.status
	 statuses.each do |s|
	 	next if s.status == status_to_skip
	 	s.voided = true
	 	s.save
	 end
=end
	 puts row['person_record_id']
end