start_date = "Start"
end_date = "End"

file = "#{Rails.root}/log/migrate.log"

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
    file = "#{Rails.root}/log/migrate.log"

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

header = [  "First name",
			"Middle name",
			"Last name", 
			"Birthdate",
			"DEN",
			"DRN",
			"Status",
			"Migrated from old system",
			"Date Migrated",
			"Date Reported",
			"Date of Death",
			"Sex",
			"Registration Type",
			"Place of Registration",
			"Died while place_of_death",
			"Printed",
			"Date Printed",
			"Place of death",
			"Place of death country",
			'Place of death district',
			"Hospital of death",
			"Other place of death",
			"Place of death TA",
			"Other place of death TA",
			"Place of death village",
			"Other place of death village",
			"Place of death foreign state",
			"Place of death foreign district",
			"Place of death foreign village",
			"Place of death foreign hospital",
			"Current country",
			"Current district",
			"Current ta",
			"Current village",
			"Current foreign state",
			"Current foreign district",
			"Current foreign village",
			"Home country",
			"Home district",
			"Home TA",
			"Home village",
			"Home foreign state",
			"Home foreign district",
			"Home foreign village",
			"Died while pregnant",
			"Delayed registration",
			"Court order",
			"Court order details",
			"Police report",
			"Police report details",
			"Reason police report not available",
			"Proof of death abroad",
			"Mother First name",
			"Mother Middle name",
			"Mother Last name",
			"Mother nationality id",
			"Mother nationality",
			"Father First name",
			"Father middle name",
			"Father Last name",
			"Father nationality ID",
			"Father nationality",
			"Informant First name",
			"Informant Middle name",
			"Informant Last name",
			"Informant Country",
			"Informant District",
			"Informant TA",
			"Informant Village",
			"Informant Postal Address",
			"Informant Foreign State",
			"Informant Foreign District",
			"Informant Foreign Town/Village",
			"Informant Foreign Postal Address",
			"Informant phone Number",
			"Informant Signed",
			"Date Informant Signed"]
write_csv_header("#{Rails.root}/db/data#{start_date}-#{end_date}.csv", header)


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
		
		id << person.id

		begin
		

			row = [	person.first_name,
					person.middle_name,
					person.last_name, 
					person.birthdate.to_time.strftime("%Y-%m-%d"),
					(person.den rescue ""),
					(person.drn rescue ""),
					status,
					migrated,
					(migrated=="Yes"? person.created_at.to_time.strftime("%Y-%m-%d") : 'N/A'),
					person.created_at.to_time.strftime("%Y-%m-%d  %H:%M:%S"),
					person.date_of_death,
					person.gender,
					person.registration_type,
					person.place_of_registration,
					person.died_while_pregnant,
					printed,
					date_printed,
					person.place_of_death,
					person.place_of_death_country,
					person.place_of_death_district,
					person.hospital_of_death,
					person.other_place_of_death,
					person.place_of_death_ta,
					person.other_place_of_death_ta,
					person.place_of_death_village,
					person.other_place_of_death_village,
					person.place_of_death_foreign_state,
					person.place_of_death_foreign_district,
					person.place_of_death_foreign_village,
					person.place_of_death_foreign_hospital,
					person.current_country,
					person.current_district,
					person.current_ta,
					person.current_village,
					person.current_foreign_state,
					person.current_foreign_district,
					person.current_foreign_village,
					person.home_country,
					person.home_district,
					person.home_ta,
					person.home_village,
					person.home_foreign_state,
					person.home_foreign_district,
					person.home_foreign_village,
					person.died_while_pregnant,
					person.delayed_registration,
					person.court_order,
					person.court_order_details,
					person.police_report,
					person.police_report_details,
					person.reason_police_report_not_available,
					person.proof_of_death_abroad,
					person.mother_first_name,
					person.mother_middle_name,
					person.mother_last_name,
					person.mother_nationality_id,
					person.mother_nationality,
					person.father_first_name,
					person.father_middle_name,
					person.father_last_name,
					person.father_nationality_id,
					person.father_nationality,
					person.informant_first_name,
					person.informant_middle_name,
					person.informant_last_name,
					person.informant_current_country,
					person.informant_current_district,
					person.informant_current_ta,
					person.informant_current_village,
					person.informant_addressline1,
					person.informant_foreign_state,
					person.informant_foreign_district,
					person.informant_foreign_village,
					person.informant_foreign_address,
					phone_number_format(person.informant_phone_number),
					person.informant_signed,
					person.informant_signature_date.present?? person.informant_signature_date.to_time.strftime("%Y-%m-%d") : 'N/A']

				write_csv_content("#{Rails.root}/db/data#{start_date}-#{end_date}.csv", row)
			puts person.id
		rescue Exception => e
				error = "#{person.id} : #{e.to_s}"
				add_to_file(error)
		end

	end
	
	page = page + 1
	

end