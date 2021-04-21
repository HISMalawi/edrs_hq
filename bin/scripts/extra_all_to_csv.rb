
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

def remove_redu_states(person_id)
    puts person_id
    statuses = PersonRecordStatus.by_person_record_id.key(person_id).each.sort_by{|s| s.created_at}
    uniqstatus = statuses.collect{|d| d.status}.uniq

    uniqstatus.each do |us|
        redundantstatuses = PersonRecordStatus.by_person_record_id_and_status.key([person_id, us]).each.sort_by{|s| s.created_at}
        #puts us 
        redundantstatuses.each_with_index do |red, i|
                if i != 0
                    begin
                        redundantstatuses[i].destroy
                    rescue
                        puts "Error : #{redundantstatuses[i].id}"
                        puts "Retry"
                        begin
                            PersonRecordStatus.find(redundantstatuses[i].id).destroy
                        rescue
                            puts "Fail"
                        end
                    end
                end
        end
    end

    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>"

    PersonRecordStatus.by_person_record_id.key(person_id).each do |s|
        if s.status.blank?
            s.destroy
        end
    end
	
    last = nil
    RecordStatus.where(person_record_id: person_id).order(:created_at).each do |d|
	couch_status = PersonRecordStatus.find(d.person_record_status_id)
	if couch_status.blank?
		d.destroy
	else 
		last = d
	end
    end
    begin
	    last = PersonRecordStatus.find(last.person_record_status_id)
	    last.voided = false
	    last.save
    rescue
	   puts "Error #{person_id}"
    end


end

def calculate_age_to_death(birthdate, date_of_death=Time.now, person_id=nil)
	if birthdate.blank?
		return "N/A"
	end
	birthdate = birthdate.to_time
	
    date_of_death = date_of_death.to_time
    different = date_of_death - birthdate
	return "#{(different / 1.day).round(1).to_i} D"
    # if (different / 1.year).round(1).to_i >= 1
    #     return "#{(different / 1.year).round(1).to_i} Y" 
    # elsif (different / 1.month).round(1) >= 1
    #     return "#{(different / 1.month).round(1).to_i} M"
    # elsif (different / 1.week).round(1) >= 1
    #     return "#{(different / 1.week).round(1).to_s} W"
    # elsif (different / 1.day).round(1) >= 1
    #     return "#{(different / 1.day).round(1).to_i} D"
    # else
    #     return "0 D"
    # end
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
			"Date Registered",
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
			"Relationship to the Deceased",
			"Flagged as COVID 19 Related?",
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
write_csv_header("/home/emkambankhani/Dump/data-with-causes#{start_date}-#{end_date}.csv", header)


count = Person.count


puts count

pagesize = 42873
pages = count / pagesize

page = 1

id = []

while page <= pages


	data = Person.all.page(page).per(pagesize).each
	data.each do |person|

		next if person.first_name.blank? && person.last_name.blank?

		date_reported = (person.informant_signature_date.present?? person.informant_signature_date.to_time.strftime("%Y-%m-%d") : 'N/A')

		date_entered_in_system = person.created_at.to_time.strftime("%Y-%m-%d")

		migrated = "No"
		if person.source_id.present?
			migrated = "Yes"
			old_record = JSON.parse(RestClient.get "http://admin:password@0.0.0.0:5984/edrs_old/#{person.source_id}") rescue nil
			if old_record.present?
				date_entered_in_system = old_record["created_at"].to_time.strftime("%Y-%m-%d")
			end
		end

		record_status = PersonRecordStatus.by_person_recent_status.key(person.id).first rescue nil


		status = record_status.status rescue nil
=begin
		if status.blank?
			last_status = PersonRecordStatus.by_person_record_id.key(person.id).each.sort_by{|d| d.created_at}.last
			
			states = {
						"DC ACTIVE" => "DC COMPLETE",
						"DC COMPLETE" => "DC COMPLETE",
						"HQ ACTIVE" =>"HQ COMPLETE",
						"HQ COMPLETE" => "MARKED HQ APPROVAL",
						"MARKED HQ APPROVAL" => "HQ CAN PRINT",
						"HQ PRINTED" => "HQ DISPATCHED"
					 }
			begin
				if states[last_status.status].blank?
				PersonRecordStatus.change_status(person, "HQ COMPLETE")
				else  
				PersonRecordStatus.change_status(person, states[last_status.status])
				end

				remove_redu_states(person.id)
			rescue
				puts "Fail to generate status"
			end
		end

		record_status = PersonRecordStatus.by_person_recent_status.key(person.id).first

		status = record_status.status rescue nil
=end	
		date_printed = ""
		printed = ""
		if ["HQ PRINTED", "HQ DISPATCHED"].include?(status)
			printed = "Yes"
		end

		if migrated =="No" && ["HQ PRINTED", "HQ DISPATCHED"].include?(status)
			date_printed = record_status.created_at.to_time.strftime("%Y-%m-%d  %H:%M:%S")
		end

		next if id.include?(person.id)

		date_registered = ""
		PersonRecordStatus.by_person_record_id_and_status.key([person.id, "HQ ACTIVE"]).each.sort_by{|d| d.created_at}.each do |d|
			if d.created_at.present?
				date_registered = (d.created_at.strftime("%Y-%m-%d") rescue "")
				break;
			end
		end

        icd = PersonICDCode.by_person_id.key(person.id).first rescue nil
		
		id << person.id
		puts person.id
		coder = User.find(person.coder)
		if coder.present?
			coders_name = "#{coder.first_name} #{coder.last_name}"
		else
			coders_name = ""
		end
		age =  calculate_age_to_death(person.birthdate,person.date_of_death, person.id)


		final_code = ""
		tentative_code = ""
		reason_tentative_differ_from_underlying = ""
		coders_final_code = ""
		reason_final_differ_from_tentative = ""
		final_code_reviewed = ""
		reason_final_code_changed = ""
		autopsy_requested = ""
		autopsy_used_for_certification = ""
		if icd.present?
			final_code = person.icd_10_code
			if icd.final_code.present?
				final_code = icd.final_code
			end
			if icd.final_code_reviewed.present? 
			 	final_code = icd.final_code_reviewed 
			end

			if icd.tentative_code.present?
				tentative_code = icd.tentative_code
			end
			if icd.reason_tentative_differ_from_underlying.present?
				reason_tentative_differ_from_underlying = icd.reason_tentative_differ_from_underlying
			end
			if icd.final_code.present?
				coders_final_code = icd.final_code
			elsif person.icd_10_code
				coders_final_code = person.icd_10_code
			end
			if icd.reason_final_differ_from_tentative.present?
				reason_final_differ_from_tentative = icd.reason_final_differ_from_tentative 
			end
			if icd.final_code_reviewed.present?
				final_code_reviewed = icd.final_code_reviewed
			end
			if icd.reason_final_code_changed.present?
				reason_final_code_changed = icd.reason_final_code_changed
			end
			autopsy_requested = person.autopsy_requested
			autopsy_used_for_certification = person.autopsy_used_for_certification
		end
		
		birthdate = ""
		if person.birthdate.present?
			birthdate = person.birthdate.to_time.strftime("%Y-%m-%d")
		end
		
		covid_flag = "No"
		# covid_record = Covid.by_person_record_id.key(person.id).first rescue nil
		# if covid_record.present?
		# 	covid_flag = "Yes"
		# end

		row = [	person.first_name,
					person.middle_name,
					person.last_name, 
					(birthdate rescue ""),
					(person.barcode rescue ""),
					(person.den rescue ""),
					(person.drn rescue ""),
					status,
					migrated,
					(migrated=="Yes"? person.created_at.to_time.strftime("%Y-%m-%d") : 'N/A'),
					person.date_of_death,
					age,
					date_reported,
					date_entered_in_system,
					date_registered,
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
					date_reported,
					(person.informant_relationship_to_deceased rescue 'Other'),
					covid_flag,
					(person.coded_at.to_time.strftime("%Y-%m-%d") rescue ""),
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
					autopsy_requested,
					autopsy_used_for_certification,
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
					coders_name,
					(tentative_code rescue ""),
					(reason_tentative_differ_from_underlying rescue ""),
					(coders_final_code rescue ""),
					(reason_final_differ_from_tentative rescue ""),
					(final_code_reviewed rescue ""),
					(reason_final_code_changed rescue ""),
					(final_code rescue "")
					]

				write_csv_content("/home/emkambankhani/Dump/data-with-causes#{start_date}-#{end_date}.csv", row)

	end
	puts page
	page = page + 1
	sleep(10)

end
