connection = ActiveRecord::Base.connection

sql = "SELECT person_record_id, count(person_record_id) as count 
	   FROM `person_record_status` WHERE status IN('HQ DISPATCHED','HQ PRINTED') 
	   AND voided = 0 GROUP BY person_record_id ORDER BY count DESC LIMIT 50";

data = connection.select_all(sql);

data.each do |row|
	 break if row['count'].to_i < 2
	 statuses = PersonRecordStatus.by_person_record_id.key(row['person_record_id']).each.sort_by{|s| s.created_at}
	 status_to_skip = statuses.last.status
	 statuses.each do |s|
	 	next if s.status == status_to_skip
	 	s.voided = true
	 	s.save
	 end
	 puts row['person_record_id']
end