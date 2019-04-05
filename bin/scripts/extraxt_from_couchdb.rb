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

statuses.each do |status|
	write_csv_header("/home/nrb-admin/hq_data/#{status.humanize}.csv", ["District","Pilot Health Facility","Non Pilot Health Facility","Home","Other"])
	District.all.each do |district|
		next if district.name.include?("City")


		if pilot[district.name].blank?
			pilot_count = "N/A"
		else
			sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}') 
										             AND a.district_code = '#{district.id}' 
										             AND a.hospital_of_death = '#{pilot[district.name]}'
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='2019-03-16' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='2019-03-31' ORDER BY d.name) t  GROUP BY  name;"
				             
			pilot_count = connection.select_all(sql).as_json.last['total'] rescue 0;
		end


		sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}')
										             AND a.district_code = '#{district.id}' 
										             AND a.place_of_death='Health Facility'
										             AND a.hospital_of_death !='#{pilot[district.name]}'
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='2019-03-16' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='2019-03-31' ORDER BY d.name) t  GROUP BY  name;"

		non_pilot_count = connection.select_all(sql).as_json.last['total'] rescue 0 rescue 0;

	    sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}') 
										             AND a.district_code = '#{district.id}' 
										             AND a.place_of_death = 'Home' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='2019-03-16' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='2019-03-31' ORDER BY d.name) t  GROUP BY  name;"

		home_count = connection.select_all(sql).as_json.last['total'] rescue 0 rescue 0

	    sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
							FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
										  inner join district d on p.district_code = d.district_id  
										       WHERE status IN ('#{status}')
										             AND a.district_code = '#{district.id}' 
										             AND a.place_of_death = 'Other' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='2019-03-16' 
										             AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='2019-03-31' ORDER BY d.name) t  GROUP BY  name;"

		other_count = connection.select_all(sql).as_json.last['total'] rescue 0
										             
		write_csv_content("/home/nrb-admin/hq_data/#{status.humanize}.csv", [district.name,pilot_count,non_pilot_count,home_count,other_count])
	end

end



