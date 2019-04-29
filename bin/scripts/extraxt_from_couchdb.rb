statuses = ["HQ ACTIVE", "HQ PRINTED"]
place_of_death = ["Home","Health Facility","Other"]

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

pilot = {
			"Lilongwe" => "Kamuzu Central Hospital",
			"Blantyre" => "Queen Elizabeth Central Hospital",
			"Ntcheu" => "Ntcheu District Hospital",
			"Chitipa" => "Chitipa District Hospital"
}

connection = ActiveRecord::Base.connection

start_date = "2019-04-01"
end_date = "2019-04-15"

#path = "/home/nrb-admin/hq_data/"

path = SETTINGS['data_path']
statuses.each do |status|
	write_csv_header("#{path}#{status.humanize}#{start_date}.csv", ["District","Died and Registered in Pilot Facility","Died in Pilot Facility but registered at DR0","Non Pilot Health Facility","Home","Other"])
	District.all.each do |district|
		next if district.name.include?("City")


		if pilot[district.name].blank?
			died_and_registered_in_pilot_count = "N/A"
			died_not_registered_in_pilot_count = "N/A"

		else
			sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}') 
										             AND a.district_code = '#{district.id}' 
										             AND a.hospital_of_death = '#{pilot[district.name]}'
										             AND a.place_of_registration = '#{pilot[district.name]}'
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{start_date}' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{end_date}' ORDER BY d.name) t  GROUP BY  name;"
				             
			died_and_registered_in_pilot_count = connection.select_all(sql).as_json.last['total'] rescue 0;

			sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}') 
										             AND a.district_code = '#{district.id}' 
										             AND a.hospital_of_death = '#{pilot[district.name]}'
										             AND a.place_of_registration != '#{pilot[district.name]}'
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{start_date}' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{end_date}' ORDER BY d.name) t  GROUP BY  name;"
				             
			died_not_registered_in_pilot_count = connection.select_all(sql).as_json.last['total'] rescue 0;
		end


		sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}')
										             AND a.district_code = '#{district.id}' 
										             AND a.place_of_death='Health Facility'
										             AND a.hospital_of_death !='#{pilot[district.name]}'
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{start_date}' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{end_date}' ORDER BY d.name) t  GROUP BY  name;"

		non_pilot_count = connection.select_all(sql).as_json.last['total'] rescue 0;

	    sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}') 
										             AND a.district_code = '#{district.id}' 
										             AND a.place_of_death = 'Home' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{start_date}' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{end_date}' ORDER BY d.name) t  GROUP BY  name;"

		home_count = connection.select_all(sql).as_json.last['total'] rescue 0

	    sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}')
										             AND a.district_code = '#{district.id}' 
										             AND a.place_of_death = 'Other' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{start_date}' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{end_date}' ORDER BY d.name) t  GROUP BY  name;"

		other_count = connection.select_all(sql).as_json.last['total'] rescue 0
										             
		write_csv_content("#{path}#{status.humanize}#{start_date}.csv", [district.name,died_and_registered_in_pilot_count,died_not_registered_in_pilot_count,non_pilot_count,home_count,other_count])
	end

end

count = Person.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

write_csv_header("#{path}COD#{start_date}.csv", ["District","Number of records"])

district_data = {}
District.all.each do |d|
	next d.name.include?("City")
	district_data[d.id] = 0
end
while page <= pages
	Person.all.page(page).per(pagesize).each do |person|
		next if person.cause_of_death1.blank?

		cause_of_death = person.cause_of_death

		created_at = (cause_of_death.created_at.to_time.strftime("%Y-%m-%d") rescue "")

		if created_at >= start_date && created_at <= end_date
				total = district_data[person.district_code].to_i + 1
				district_data[person.district_code] = total

		end
	end

	puts page
	page = page + 1
end

District.all.each.sort_by { |d| d.id}.each do |d|
	next if d.name.include?("City")
	next if district_data[d.id].to_i == 0
	write_csv_content("#{path}COD#{start_date}.csv", [d.name,district_data[d.id]])
end

