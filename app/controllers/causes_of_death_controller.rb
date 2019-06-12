class CausesOfDeathController < ApplicationController
	def view
		
	end

	def search_causes
		data = []
		offset = (params[:page].to_i rescue 0) * 40
		(RecordICDCode.all.order(:created_at).offset(offset).limit(40) || []).each do |icd_code|
			person = Person.find(icd_code.person_id)
			cause_of_death = icd_code
			next if person.blank?
			row = {
					"den" => (person.den rescue nil),
					"barcode" => (person.barcode rescue nil),
					"gender" => person.gender,
					"date_of_death" => person.date_of_death,
					"cause_of_death1" => person.cause_of_death1,
					"icd_10_1" => person.icd_10_1,
					"cause_of_death2" => person.cause_of_death2,
					"icd_10_2" => person.icd_10_2,
					"cause_of_death3" => person.cause_of_death3,
					"icd_10_3" => person.icd_10_3,
					"cause_of_death4" => person.cause_of_death4,
					"icd_10_4" => person.icd_10_4,
					"_id" => person.id

			}

			if cause_of_death.icd_10_1_reviewed.present?
				row["icd_10_1"] = cause_of_death.icd_10_1_reviewed
			end

		    if cause_of_death.icd_10_2_reviewed.present?
				row["icd_10_2"] = cause_of_death.icd_10_2_reviewed
		    end	

		    if cause_of_death.icd_10_3_reviewed.present?
				row["icd_10_3"] = cause_of_death.icd_10_3_reviewed
			end

			row["final_code"] = cause_of_death.final_code
			
			row["final_code_reviewed"] = (cause_of_death.final_code_reviewed rescue "")
	

			data << row
		end
		render :text => data.to_json
	end

	def edit
		@person = Person.find(params[:id])
		
	end
end
