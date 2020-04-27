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

def format_conditions(conditions)
        keys = conditions.keys
        cause_and_code = []
        keys.each do |key|
                cause_and_code << "#{conditions[key]['cause']}(#{conditions[key]['icd_code']})"
        end
        puts cause_and_code.join(",")
        return (cause_and_code.join(",") rescue "")
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

def calculate_age_to_death(birthdate, date_of_death=Time.now)
    birthdate = birthdate.to_time
    date_of_death = date_of_death.to_time
    different = date_of_death - birthdate
    if (different / 1.year).round(1).to_i >= 1
        return "#{(different / 1.year).round(1).to_i} Y" 
    elsif (different / 1.month).round(1) >= 1
        return "#{(different / 1.month).round(1).to_i} M"
    elsif (different / 1.week).round(1) >= 1
        return "#{(different / 1.week).round(1).to_s} W"
    elsif (different / 1.day).round(1) >= 1
        return "#{(different / 1.day).round(1).to_i} D"
    else
        return "0 D"
    end
  end
#`bundle exec rake edrs:build_mysql`

header = [  "First name",
			"Middle name",
			"Last name", 
			"Birthdate",
			"Barcode",
			"DEN",
			"DRN",
			"Status",
			"Migrated from old system",
			"Date Migrated",
			"Date of Death",
			"Age",
			"Date Reported",
			"Date Entered in EDRS",
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
			"Date Informant Signed",

			"Date Coded",
			"Condition (a)",
			"Code (a)",			
			"Condition (b)",
			"Code (b)",
			"Condition (c)",
			"Code (c)",
			"Condition (d)",
			"Code (d)",
			"Other significant Cause (1)",
			"Other significant Code (1)",
			"Other significant Cause (2)",
			"Other significant Code (2)",
			"Other significant Cause (3)",
			"Other significant Code (3)",
			"Autopsy requested",
			"Autopsy used",
			"Manner of Death",
		    "Other manner of death specify",
			"How did it occur(If accidental death)",
			"Other accidental death specify",
			"Certifier's Name",
			"Certifier's MCM Number",
			"Certifier signed?",
			"Date certifier signed",
			"Certifier's Designation",
			"Other certifier's designation specify",
			"Name of Coder",
			"Tentantive Code",
			"Reason Differnt from Undelying",
			"Coder's Final Code",
			"Reason Differnt from Tentantive",
			"Supervisors's Final Code",
			"Reason Supervisor's code is different",
			"Final Code"
			]
write_csv_header("#{Rails.root}/db/causes#{start_date}-#{end_date}.csv", header)


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
=begin
		if record_status.blank?
			statuses = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|s| s.created_at}
	 		last_status = statuses.last
	 		if last_status.blank?
	 			record_status = PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC ACTIVE",
                                  :prev_status => nil,
                                  :reprint => 0,
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
=end

		status = record_status.status rescue nil

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
		
		id << person.id

		coder = User.find(person.coder)
		age =  calculate_age_to_death(person.birthdate,person.date_of_death)

		final_code = icd.final_code_reviewed.present? icd.final_code_reviewed : (icd.final_code.present? ? icd.final_code : person.icd_10_code)

		begin
		

			row = [	person.first_name,
					person.middle_name,
					person.last_name, 
					person.birthdate.to_time.strftime("%Y-%m-%d"),
					(person.barcode rescue ""),
					(person.den rescue ""),
					(person.drn rescue ""),
					status,
					migrated,
					(migrated=="Yes"? person.created_at.to_time.strftime("%Y-%m-%d") : 'N/A'),
					person.date_of_death,
					age,
					person.informant_signature_date,
					person.created_at.to_time.strftime("%Y-%m-%d  %H:%M:%S"),
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
					person.informant_signature_date.present?? person.informant_signature_date.to_time.strftime("%Y-%m-%d") : 'N/A',
					person.coded_at.to_time.strftime("%Y-%m-%d"),
					(person.cause_of_death1 rescue ""),
					(person.icd_10_1 rescue " "),
					(person.cause_of_death2 rescue ""),
					(person.icd_10_2 rescue " "),
					(person.cause_of_death3 rescue ""),
					(person.icd_10_3 rescue " "),
					(person.cause_of_death4 rescue ""),
					(person.icd_10_4 rescue " "),
					(person.cause_of_death_conditions["1"]["cause"] rescue ""),
					(person.cause_of_death_conditions["1"]["icd_code"] rescue ""),
					(person.cause_of_death_conditions["2"]["cause"] rescue ""),
					(person.cause_of_death_conditions["2"]["icd_code"] rescue ""),
					(person.cause_of_death_conditions["3"]["cause"] rescue ""),
					(person.cause_of_death_conditions["3"]["icd_code"] rescue ""),
					person.autopsy_requested,
					person.autopsy_used_for_certification,
					person.manner_of_death,
					person.other_manner_of_death,
					person.death_by_accident,
					person.other_death_by_accident,
					person.certifier_name,
					person.certifier_license_number,
					person.certifier_signed,
					person.date_certifier_signed,
					person.position_of_certifier,
					person.other_position_of_certifier,
					("#{coder.first_name} #{coder.last_name}" ),
					(icd.tentative_code rescue ""),
					(icd.reason_tentative_differ_from_underlying rescue ""),
					(icd.final_code.present? ? icd.final_code : person.icd_10_code),
					(icd.reason_final_differ_from_tentative rescue ""),
					(icd.final_code_reviewed rescue ""),
					(icd.reason_final_code_changed rescue ""),
					final_code
					]



				write_csv_content("#{Rails.root}/db/causes#{start_date}-#{end_date}.csv", row)
			puts "#{person.id}: #{format_conditions(person.cause_of_death_conditions)}"
		rescue Exception => e
				error = "#{person.id} : #{e.to_s}"
				add_to_file(error)
		end

	end
	
	page = page + 1
	

end
