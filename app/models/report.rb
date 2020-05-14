class Report < ActiveRecord::Base
	def self.causes_of_death(params)
		district_query = ''
		if params[:district].present?
			district_query = " AND district_code = '#{District.by_name.key(params[:district]).first.id}'" 
		end

		date_query = ''
		if params[:start_date].present?

			date_query = " AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >= '#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
				           AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <= '#{params[:end_date].to_time.strftime("%Y-%m-%d")}' "
		end

		autopsy_query = ''
		if params[:autopsy_requested].present?
			autopsy_query = "AND autopsy_requested = '#{params[:autopsy_requested]}'"
		end

        age_query = ''

		if params[:age_operator].present?
	        if params[:age_operator] ==  "=> Age <="
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) >= #{params[:start_age]} AND (DATEDIFF(date_of_death,birthdate)/365) <= #{params[:end_age]} "
	        else
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) #{params[:age_operator]} #{params[:start_age]} "
	        end
		end

		connection = ActiveRecord::Base.connection
		codes_query = "SELECT distinct icd_10_code FROM people WHERE icd_10_code IS NOT NULL LIMIT 5000"
		final_code_query = "SELECT distinct final_code FROM person_icd_codes WHERE final_code IS NOT NULL LIMIT 5000"
		codes = (connection.select_all(codes_query).as_json.collect{|code| code['icd_10_code']} + connection.select_all(final_code_query).as_json.collect{|code| code['final_code']}).uniq
		data  = {}

		codes.each do |code|

			data[code] = {}
			gender = ['Male','Female']
			gender.each do |g|
				query = "SELECT count(*) as total FROM people p INNER JOIN person_icd_codes c ON p.person_id = c.person_id WHERE  gender='#{g}' AND c.final_code = '#{code}' #{district_query} #{date_query} #{age_query} #{autopsy_query}"
				data[code][g] = connection.select_all(query).as_json.last['total'] rescue 0
			end			
		end
		return data

	end

	def self.manner_of_death(district= nil,start_date = nil,end_date = nil, age_operator = nil, start_age= nil, end_age =nil, autopsy =nil )
		district_query = ''
		if district.present?
			district_query = " AND district_code = '#{District.by_name.key(district).first.id}'" 
		end

		date_query = ''
		if start_date.present?
			date_query = " AND date_of_death >=Date('#{start_date}') AND date_of_death <=Date('#{end_date}')"
		end

		autopsy_query = ''
		if autopsy.present?
			autopsy_query = "AND autopsy_requested = '#{autopsy}'"
		end

        age_query = ''

		if age_operator.present?
	        if age_operator ==  "=> Age <="
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) >= #{start_age} AND (DATEDIFF(date_of_death,birthdate)/365) <= #{end_age} "
	        else
	            age_query = " AND (DATEDIFF(date_of_death,birthdate)/365) #{age_operator} #{start_age} "
	        end
		end

		connection = ActiveRecord::Base.connection
		manner_of_death = ['Natural','Accident','Homicide','Suicide','Pending Investigation','Could not be determined','Other']
		data  = {}
		manner_of_death.each do |manner|
			data[manner] = {}
			gender = ['Male','Female']
			gender.each do |g|
				query = "SELECT count(*) as total FROM people WHERE  gender='#{g}' AND manner_of_death = '#{manner}' #{district_query} #{date_query} #{age_query} #{autopsy_query}"
				data[manner][g] = connection.select_all(query).as_json.last['total'] rescue 0
			end
		end

		return data
	end

	def self.general(params)
		district_query = ""
		if params[:district].present? && params[:district] != "All"
			district_query = "AND person_record_status.district_code = '#{params[:district]}'"
		end
		if params[:time_line].blank?
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		else
			case params[:time_line]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Date range"
				start_date = params[:start_date].to_time.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	params[:end_date].to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			end
		end
		status = params[:status].present? ? params[:status] : 'DC ACTIVE'
		total_male   =  0
	    total_female =  0
	    gender = ['Male','Female']
	    connection = ActiveRecord::Base.connection

	    reg_type = {}
	    types = ["Natural Deaths","Unnatural Deaths","Dead on Arrival","Unclaimed bodies","Missing Persons","Deaths Abroad"]
	    types.each do |type|
	    	reg_type[type] = {}
	    	gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}' #{district_query} 
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}' 
					 	 AND people.registration_type = '#{type}'"
				reg_type[type][g] = connection.select_all(query).as_json.last['total'] rescue 0
	    	end
	    end

	    delayed = {}
	    ["Yes","No"].each do |response|
	    	delayed[response] = {}
	    	gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}' #{district_query}
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}'
	    				 AND people.delayed_registration = '#{response}'"
				delayed[response][g] = connection.select_all(query).as_json.last['total'] rescue 0
	    	end
		end

		age_estimate = {}
		["Yes","No"].each do |response|
			mapped = {"Yes" => 1, "No" => 0}
			age_estimate[response]  = {} 

			gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}' #{district_query}
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}' 
	    				 AND people.birthdate_estimated = '#{mapped[response]}'"
				age_estimate[response][g] = connection.select_all(query).as_json.last['total'] rescue 0
			end
		end

		places = {}
		["Home","Health Facility", "Other"].each do |place|
			places[place] = {}
			gender.each do |g|
	    		query = "SELECT count(*) as total, gender , status, person_record_status.created_at , person_record_status.updated_at 
	    				 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 	 WHERE status = '#{status}' AND gender='#{g}' #{district_query} 
					 	 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}' 
	    				 AND people.place_of_death = '#{place}' "
				places[place][g] = connection.select_all(query).as_json.last['total'] rescue 0

				if g =="Male"
					total_male = total_male + places[place][g]
				else
					total_female = total_female + places[place][g]
				end
	    	end
		end

		total = {"Total" =>{"Male" => total_male, "Female" => total_female}}.as_json
		data = {
				"Registration Type" => reg_type,
				"Delayed Registration"=> delayed,
				"Age Estimated"=> age_estimate,
				"Place of Death" => places,
				"#{status}" => total }


		return data
	end

	def self.proficiency(start_date, end_date)
		    sample_details = []
		    sample = ProficiencySample.all.each
		    sample.each do |sp|
		        user = User.find(sp.coder_id)
		        sample_details << { 
		         					  id: sp.id,
		                              name: "#{user.first_name} #{user.last_name}",
		                              sample: sp.sample,
		                              reviewed: sp.reviewed,
		                              sample_id: sp.id,
		                              date_sampled: sp.date_sampled,
		                              final_result: sp.final_result.to_f.round(2),
		                              comment: sp.comment
		                            }
		    end
		    return sample_details
	end

	def self.district_registered_and_gender(params)
		district_query = ""
		if params[:district].present? && params[:district] != "All"
			district_query = "AND a.district_code = '#{District.by_name.key(params[:district]).first.id}'"
		end
		gender_query =""
		if params[:gender].present? && params[:gender] != "Total"
			gender_query = "AND gender='#{params[:gender]}'"
		end
		
		status = params[:status].present? ? params[:status] : 'DC ACTIVE'

	
		start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
		end_date =	params[:end_date].to_time.strftime("%Y-%m-%d")


		connection = ActiveRecord::Base.connection

		query = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
				 FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
				 inner join district d on p.district_code = d.district_id  
				 WHERE status IN ('#{params[:status]}') #{district_query}  #{gender_query}
				 AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >= '#{start_date}' 
				 AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <= '#{end_date}') t"
		
		return {:count => (connection.select_all(query).as_json.last['total'] rescue 0) , :gender =>params[:gender], :district => params[:district]}
	end

	def self.connection
		return ActiveRecord::Base.connection
	end
	def self.by_place_of_death(params)
		pilot = {
			"Lilongwe" => "Kamuzu Central Hospital",
			"Blantyre" => "Queen Elizabeth Central Hospital",
			"Ntcheu" => "Ntcheu District Hospital",
			"Chitipa" => "Chitipa District Hospital"
		}
		count = 0
		district = District.by_name.key(params[:district]).first
		case params[:category]
		when "died_and_registered_at_pilot"
			if pilot[district.name].blank?
				count = 0
			else
		    	sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
				   	FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
				   	inner join district d on p.district_code = d.district_id  
				   	WHERE status IN ('#{params[:status]}') AND a.district_code = '#{district.id}' 
				    AND a.hospital_of_death = '#{pilot[params[:district]]}'
					AND a.place_of_registration = '#{pilot[params[:district]]}'
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}' AND name = '#{district.name}'
					ORDER BY d.name) t  GROUP BY  name;"

				count = self.connection.select_all(sql).as_json.last['total'] rescue 0;
			end
		when "died_in_pilot_and_registered_at_dro"
			if pilot[district.name].blank?
				count = 0
			else
				sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
				    FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
					inner join district d on p.district_code = d.district_id  
					WHERE status IN ('#{params[:status]}') 
					AND a.district_code = '#{district.id}' 
					AND a.hospital_of_death = '#{pilot[params[:district]]}'
					AND a.place_of_registration != '#{pilot[params[:district]]}'
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}' AND name = '#{district.name}'
					ORDER BY d.name) t  GROUP BY  name;"
				count = self.connection.select_all(sql).as_json.last['total'] rescue 0;
			end			
		when "non_pilot"
			sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
				   FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
					inner join district d on p.district_code = d.district_id  
					WHERE status IN ('#{params[:status]}')
					AND a.district_code = '#{district.id}' AND a.place_of_death='Health Facility'
					AND a.hospital_of_death !='#{pilot[params[:district]]}'
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}' AND name = '#{district.name}'
					ORDER BY d.name) t  GROUP BY  name;"
			count = self.connection.select_all(sql).as_json.last['total'] rescue 0;
		when "home"
	    	sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
					FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
					inner join district d on p.district_code = d.district_id  
					WHERE status IN ('#{params[:status]}') 
					AND a.district_code = '#{district.id}' 
					AND a.place_of_death = 'Home' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}' AND name = '#{district.name}'
					 ORDER BY d.name) t  GROUP BY  name;"

			count = connection.select_all(sql).as_json.last['total'] rescue 0
		when "other"
	    	sql = "SELECT count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
					FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
					inner join district d on p.district_code = d.district_id  
					WHERE status IN ('#{params[:status]}') AND a.district_code = '#{district.id}' AND a.place_of_death = 'Other' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}' AND name = '#{district.name}'
					 ORDER BY d.name) t  GROUP BY  name;"

			count = connection.select_all(sql).as_json.last['total'] rescue 0
		when  "Total"
	    	sql = "SELECT name, count(*) as total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
					FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
					inner join district d on p.district_code = d.district_id  
					WHERE status IN ('#{params[:status]}') AND a.district_code = '#{district.id}' AND a.place_of_death IN('Health Facility','Home','Other')
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
					AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}' AND name = '#{district.name}'
					ORDER BY d.name) t  GROUP BY  name;"
			count = connection.select_all(sql).as_json.last['total'] rescue 0					
		end
		return {:count => count , :category =>params[:category], :district => params[:district]}
	end

	def self.audits(params)
		offset = params[:page].to_i  *  40
		query = "DATE_FORMAT(created_at,'%Y-%m-%d') BETWEEN '#{params[:start_date]}' AND '#{params[:end_date]}'"
		#query = "DATE_FORMAT(created_at,'%Y-%m-%d') BETWEEN '2019-01-01' AND '2019-05-21'"
		data = []

		AuditRecord.where(query).order("created_at DESC").limit(40).offset(offset).each do |audit|
			entry = {}
			user = User.find(audit.user_id)
			next if user.blank?
			entry["username"] = user.username
			entry["name"] = "#{user.first_name} #{user.last_name} (#{user.role})"
			entry["audit_type"] =  audit.audit_type
			entry["change"] = (audit.model.present? ? audit.model.humanize : "N/A")
			entry["previous_value"] = (audit.previous_value.present? ? audit.previous_value : "N/A")
			entry["current_value"] = (audit.current_value.present? ? audit.current_value : "N/A")
			entry["reason"] =  audit.reason
			entry["time"] = audit.created_at.to_time.strftime("%Y-%m-%d  %H:%M")
			data << entry
		end
		return data
	end	

	def self.covid(params)
		connection = ActiveRecord::Base.connection
		district_query =""
		gender_query =""

		if params[:district].present? && params[:district] != "All"
			district_query = "AND d.name = '#{params[:district]}'"
		end

		if params[:gender].present? && params[:gender] != "Total"
			gender_query = "AND gender='#{params[:gender]}'"
		end

		sql = "SELECT COUNT(*) as total FROM  people p INNER JOIN covid_record c ON p.person_id = c.person_record_id
				INNER JOIN district d on p.district_code = d.district_id 
				WHERE
				DATE_FORMAT(c.created_at,'%Y-%m-%d') >='#{params[:start_date].to_time.strftime("%Y-%m-%d")}' 
				AND DATE_FORMAT(c.created_at,'%Y-%m-%d') <='#{params[:end_date].to_time.strftime("%Y-%m-%d")}'
				#{gender_query}
				#{district_query};"
		
		count = connection.select_all(sql).as_json.last['total'] rescue 0
		return {:count => count , :gender =>params[:gender], :district => params[:district]}
	end
end