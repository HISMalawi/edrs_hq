stat = Time.now.last_month
query = "SELECT 
			first_name,
			middle_name,
			last_name, 
			birthdate,
			c.den,
			c.drn,
			date_of_death,
			gender,
			people.registration_type,
			place_of_registration,
			place_of_death,
			place_of_death_country,
			place_of_death_district,
			hospital_of_death,
			other_place_of_death,
			place_of_death_ta,
			other_place_of_death_ta
			place_of_death_village,
			other_place_of_death_village,
			place_of_death_foreign_state,
			place_of_death_foreign_district,
			place_of_death_foreign_village,
			place_of_death_foreign_hospital,
			current_country,
			current_district,
			current_ta,
			current_village,
			current_foreign_state,
			current_foreign_district,
			current_foreign_village,
			home_country,
			home_district,
			home_ta,
			home_village,
			home_foreign_state,
			home_foreign_district,
			home_foreign_village,
			died_while_pregnant,
			delayed_registration,
			court_order,
			court_order_details,
			police_report,
			police_report_details,
			reason_police_report_not_available,
			proof_of_death_abroad,
			person_record_status.status,
			mother_first_name,
			mother_middle_name,
			mother_last_name,
			mother_nationality_id,
			mother_nationality,
			father_first_name,
			father_middle_name,
			father_last_name,
			father_nationality_id,
			father_nationality
		 FROM person_record_status 
		 INNER JOIN people ON people.person_id = person_record_status.person_record_id 
		 INNER JOIN (SELECT a.person_record_id,a.identifier as den, b.identifier as drn
		 FROM person_identifier a 
			    INNER JOIN  person_identifier b ON a.person_record_id = b.person_record_id 
			    WHERE a.identifier_type = 'DEATH ENTRY NUMBER' AND b.identifier_type = 'DEATH REGISTRATION NUMBER') 
		c ON people.person_id = c.person_record_id
		WHERE person_record_status.voided = 0 AND person_record_status.status LIKE '%HQ%' ORDER BY den;"
Kernel.system("mysql -u root -pMnzysk123 edrs -e \"#{query}\" | tr '\t' ',' > #{Rails.root}/db/data.csv")