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
#`bundle exec rake edrs:build_mysql`

header = 		[   "First name",
					"Middle name",
					"Last name", 
					"Birthdate",
					"Date of Death",
					"Sex",
					"Registration Type",
					"Place of Death",
					"Place of Death District",
					"Hospital of Death",
					"Place of Registration",
                    "Barcode",
					"DEN",
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
					"Tentantive Code",
					"Reason Differnt from Undelying",
					"Coder's Final Code",
					"Reason Differnt from Tentantive",
					"Supervisors's Final Code",
					"Reason Supervisor's code is different"]
file = "#{Rails.root}/db/cause_of_death-#{Time.now}.csv"


write_csv_header(file, header)


count = Person.count


puts count

pagesize = 200
pages = count / pagesize

page = 1

id = []

sql = "SELECT person_id FROM people WHERE cause_of_death1 IS NOT NULL"
connection = ActiveRecord::Base.connection
data = connection.select_all(sql).as_json
data.each do |sqlid|
		person = Person.find(sqlid['person_id'])
		next if person.blank?
		migrated = "No"
		source_id = (person.source_id rescue nil)
		if source_id.present?
			migrated = "Yes"
		end

		next if migrated == "Yes"

		record_status = PersonRecordStatus.by_person_recent_status.key(person.id).last

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
		next if icd.blank?
#		raise icd.inspect

		next if person.cause_of_death1.blank?
		#next if person.icd_10_1.blank?other_manner_of_death
		
		#raise person.inspect
		id << person.id

		#raise person.cause_of_death_conditions.inspect if person.cause_of_death_conditions.present?

		row = [	"###########",
					"###########",
					"###########", 
					person.birthdate.to_time.strftime("%Y-%m-%d"),
					person.date_of_death.to_time.strftime("%Y-%m-%d"),
					person.gender,
					person.registration_type,	
					person.place_of_death,
					person.place_of_death_district,
					person.hospital_of_death,
					person.place_of_registration,
					(person.barcode rescue ""),
					(person.den rescue ""),
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
					(icd.tentative_code rescue ""),
					(icd.reason_tentative_differ_from_underlying rescue ""),
					(icd.final_code.present? ? icd.final_code : person.icd_10_code),
					(icd.reason_final_differ_from_tentative rescue ""),
					(icd.final_code_reviewed rescue ""),
					(icd.reason_final_code_changed rescue "")]
		puts row.to_s

		write_csv_content(file, row)
		puts person.id

end
