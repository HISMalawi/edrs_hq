sql = "CREATE TABLE IF NOT EXISTS person_icd_codes (
							person_icd_code_id varchar(255) NOT NULL UNIQUE,
                            person_id varchar(255) NOT NULL UNIQUE,
                            tentative_code varchar(20) NOT NULL,
  							reason_tentative_differ_from_underlying varchar(255) DEFAULT NULL,
 							final_code varchar(20) DEFAULT NULL,
							reason_final_differ_from_tentative varchar(255) DEFAULT NULL,
							icd_10_1_reviewed varchar(20) DEFAULT NULL,
							reason_icd_10_1_changed varchar(255) DEFAULT NULL,
							icd_10_2_reviewed varchar(20) DEFAULT NULL,
							reason_icd_10_2_changed varchar(255) DEFAULT NULL,
							icd_10_3_reviewed varchar(20) DEFAULT NULL,
							reason_icd_10_3_changed varchar(255) DEFAULT NULL,
							icd_10_4_reviewed varchar(20) DEFAULT NULL,
							reason_icd_10_4_changed varchar(255) DEFAULT NULL,
							tentative_code_reviewed varchar(20) DEFAULT NULL,
							reason_tentative_code_changed varchar(255) DEFAULT NULL,
							final_code_reviewed varchar(20) DEFAULT NULL,
							reason_final_code_changed varchar(255) DEFAULT NULL,
							review_results varchar(10) DEFAULT NULL ,
							other_significant_causes TEXT,
							created_at datetime NOT NULL,
			                updated_at datetime NOT NULL,
                          PRIMARY KEY (person_icd_code_id)
                        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
connection = ActiveRecord::Base.connection;
connection.execute(sql);

count = Person.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

ids = []

while page <= pages
	Person.all.page(page).per(pagesize).each do |person|
		next if person.cause_of_death1.blank?
		next if person.icd_10_code.blank?
		next if ids.include?(person.id)
		cause_of_death = person.cause_of_death

		if cause_of_death.blank?
      		person_icd_code = PersonICDCode.create({
                  :person_id => person.id,
                  :tentative_code => person.icd_10_code,
                  :final_code =>person.icd_10_code
        	})			
		else
			fields  = cause_of_death.keys.sort
		    sql_record = RecordICDCode.where(person_id: person.id).first
		    sql_record = RecordICDCode.new if sql_record.blank?
		    fields.each do |field|
		      next if field == "type"
		      next if field == "_rev"
		      next if field == "source_id"

		      if field =="_id"
		          sql_record["person_icd_code_id"] = cause_of_death[field]
		      else
		          sql_record[field] = cause_of_death[field]
		      end
		    end
		    sql_record.save
		end
		ids << person.id
	end

	puts page
	page = page + 1
end