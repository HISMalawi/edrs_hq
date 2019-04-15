start_date = "Start"
end_date = "End"

file = "#{Rails.root}/log/cause.log"

if !File.exist?(file)
	File.open(file, "w+") do |f|
		  f.write("Log for #{Time.now}")
	end
else
	File.open(file, "a+") do |f|
	  f.write("\nLog for #{Time.now}")
	end	
end

def add_to_file(content)
    file = "#{Rails.root}/log/cause.log"

	File.open(file, "a+") do |f|
	  f.write("\n#{content}")
	end
end

statuses = ["DC ACTIVE","DC COMPLETE","DC INCOMPLETE","DC PENDING","HQ ACTIVE", "HQ COMPLETE"]

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

def phone_number_format(number)
	if number == "Unknown"
		return number
	else
		digits = []
		i = 0
		number.gsub("+","").split("").each do |d|
			if i == 3 && d == "0"		
				next
			end
			digits << d
			i = i + 1
		end

		#raise digits.inspect

		phone_number = "+"
		length = digits.length
		i = 0;

		while i < length
			if i % 3 == 0 && i != 0 
				phone_number = "#{phone_number} #{digits[i]}"
			else
				phone_number = "#{phone_number}#{digits[i]}"
			end
			i = i + 1
		end
		return phone_number
	end

	return number
end
#`bundle exec rake edrs:build_mysql`

header = 		[  "First name",
					"Middle name",
					"Last name", 
					"Birthdate",
					"Date of Death",
					"Sex",
					"Place of Death",
					"Place of Death District",
					"Hospital of Death",
					"Place of Registration",
					"DEN",
					"DRN",
					"Status",
					"Date Coded",
					"Condition (a)",
					"Code (a)",			
					"Condition (b)",
					"Code (b)",
					"Condition (c)",
					"Code (c)",
					"Condition (d)",
					"Code (d)",
					"Autopsy requested",
					"Autopsy used",
					"Manner of Death",
					"Manner of Injury/ Accident",
					"Tentantive Code",
					"Reason Differnt from Undelying",
					"Final Code",
					"Reason Differnt from Tentantive"]

write_csv_header("#{Rails.root}/db/cause_of_death.csv", header)


count = Person.count


puts count

pagesize = 200
pages = count / pagesize

page = 1

id = []

while page <= pages


	data = Person.all.page(page).per(pagesize).each
	data.each do |person|

		migrated = "No"
		if person.source_id.present?
			migrated = "Yes"
		end

		next if migrated == "Yes"

		record_status = PersonRecordStatus.by_person_recent_status.key(person.id).first
		if record_status.blank?
			statuses = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|s| s.created_at}
	 		last_status = statuses.last
	 		if last_status.blank?
	 			record_status = PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC ACTIVE",
                                  :prev_status => nil,
                                  :reprint => false,
                                  :comment => "Status Corrected",
                                  :district_code => person.district_code,
                                  :creator => (person.creator rescue User.first.id)})
	 		else
	 			last_status.voided = false
	 			last_status.save
	 			record_status = last_status	
	 		end
			status = record_status.status
		else
			status = record_status.status
		end


		date_printed = ""
		printed = ""
		if ["HQ PRINTED", "HQ DISPATCHED"].include?(status)
			printed = "Yes"
		end

		if migrated =="No" && ["HQ PRINTED", "HQ DISPATCHED"].include?(status)
			date_printed = record_status.created_at.to_time.strftime("%Y-%m-%d  %H:%M:%S")
		end

		next if id.include?(person.id)

		icd = PersonICDCode.by_person_id.key(person.id).first

		next if person.cause_of_death1.blank?
		
		id << person.id

			row = [	person.first_name,
					person.middle_name,
					person.last_name, 
					person.birthdate.to_time.strftime("%Y-%m-%d"),
					person.date_of_death,
					person.gender,
					person.place_of_death,
					person.place_of_death_district,
					person.hospital_of_death,
					person.place_of_registration,
					(person.den rescue ""),
					(person.drn rescue ""),
					status,
					person.coded_at.to_time.strftime("%Y-%m-%d"),
					(person.cause_of_death1 rescue ""),
					(person.icd_10_1 rescue " "),
					(person.cause_of_death2 rescue ""),
					(person.icd_10_2 rescue " "),
					(person.cause_of_death3 rescue ""),
					(person.icd_10_3 rescue " "),
					(person.cause_of_death4 rescue ""),
					(person.icd_10_4 rescue " "),
					person.autopsy_requested,
					person.autopsy_used_for_certification,
					person.manner_of_death,
					person.death_by_accident,
					icd.tentative_code,
					icd.reason_tentative_differ_from_underlying,
					icd.final_code,
					icd.reason_final_differ_from_tentative]

				write_csv_content("#{Rails.root}/db/cause_of_death.csv", row)
			puts person.id

	end
	
	page = page + 1
	

end