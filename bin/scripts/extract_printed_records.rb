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

connection = ActiveRecord::Base.connection

header = ["District", "July 2018", "August 2018", "September 2018" , "October 2018", "November 2018" , "December 2018" , "January 2019", "February 2019" , "March 2019" ]
count = (header.length)  - 1 
write_csv_header("#{Rails.root}/db/printed.csv", header)

DistrictRecord.all.each do |d|
	next if d.name.include?("City")
	data  = [d.name]
	start_date = Date.parse("2018-07-01")
	end_date = start_date.end_of_month
	
	i = 0
	while i < count
		sql = "SELECT COUNT(a.person_record_id) as total FROM (SELECT DISTINCT person_record_id FROM person_record_status 
			   WHERE  DATE_FORMAT(created_at,'%Y-%m-%d') >= '#{start_date.strftime("%Y-%m-%d 0:00:00:000Z")}' 
			   AND DATE_FORMAT(created_at,'%Y-%m-%d') <= '#{end_date.strftime("%Y-%m-%d 23:59:59.999Z")}'
               AND district_code ='#{d.id}' AND status IN('HQ DISPATCHED', 'HQ PRINTED')) a"

        total = connection.select_all(sql).as_json.last['total'] rescue 0

        data << total	

        start_date = end_date + 1.day
        end_date = end_date = start_date.end_of_month

		i = i + 1
	end
	write_csv_content("#{Rails.root}/db/printed.csv", data)

	puts "#{d.name}"
end