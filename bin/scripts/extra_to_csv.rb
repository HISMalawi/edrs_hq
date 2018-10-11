start_date = "2018-06-01"
end_date = "2018-06-31"

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

#`bundle exec rake edrs:build_mysql`

header = [  "First name",
			"Middle name",
			"Last name", 
			"Birthdate",
			"DEN",
			"DRN",
			"Date of Death",
			"Sex",
			"Registration Type",
			"Place of Registration",
			"Died while place_of_death",
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
			"Status",
			"Mother First name",
			"Mother Middle name",
			"Mother Last name",
			"Mother nationality id",
			"Mother nationality",
			"Father First name",
			"Father middle name",
			"Father Last name",
			"Father nationality ID",
			"Father nationality"]
write_csv_header("#{Rails.root}/db/data#{start_date}-#{end_date}.csv", header)

connection = ActiveRecord::Base.connection

=begin
	
query = "SELECT count(*) as total FROM person_record_status 
			WHERE status IN('#{statuses.join("','")}')
			AND DATE_FORMAT(person_record_status.created_at,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}' AND voided = 0"
	
=end

query = "SELECT count(*) as total FROM person_record_status 
			WHERE  DATE_FORMAT(person_record_status.created_at,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}' AND voided = 0"
count  = connection.select_all(query).as_json.last['total'] rescue 0

puts count

pagesize = 200
pages = count / pagesize

page = 1

id = []

while page <= pages

=begin
	
query = "SELECT * FROM person_record_status 
			WHERE status IN('#{statuses.join("','")}')
			AND DATE_FORMAT(person_record_status.created_at,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}' AND voided = 0
			ORDER BY person_record_id
			LIMIT #{pagesize} OFFSET #{pagesize * (page - 1)} "	
	
=end
	query = "SELECT * FROM person_record_status 
			WHERE  DATE_FORMAT(person_record_status.created_at,'%Y-%m-%d') BETWEEN '#{start_date}' AND '#{end_date}' AND voided = 0
			ORDER BY person_record_id
			LIMIT #{pagesize} OFFSET #{pagesize * (page - 1)} "	
	data = connection.select_all(query).as_json
	data.each do |status|

		person = Person.find(status['person_record_id'])

		#next if person.place_of_death != 'Health Facility'

		next if id.include?(person.id)
		
		id << status['person_record_id']

		row = [	person.first_name,
				person.middle_name,
				person.last_name, 
				person.birthdate,
				(person.den rescue ""),
				(person.drn rescue ""),
				person.date_of_death,
				person.gender,
				person.registration_type,
				person.place_of_registration,
				person.died_while_pregnant,
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
				status['status'],
				person.mother_first_name,
				person.mother_middle_name,
				person.mother_last_name,
				person.mother_nationality_id,
				person.mother_nationality,
				person.father_first_name,
				person.father_middle_name,
				person.father_last_name,
				person.father_nationality_id,
				person.father_nationality]

			write_csv_content("#{Rails.root}/db/data#{start_date}-#{end_date}.csv", row)
		puts status['person_record_id']

	end
	
	page = page + 1
	
end