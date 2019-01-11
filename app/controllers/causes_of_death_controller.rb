class CausesOfDeathController < ApplicationController
	def view
		
	end

	def search_causes
		data = []

		Person.by_coder_and_coded_at.page(params[:page]).per(50).each do |variable|
			variable["den"] = variable.den
			variable["barcode"] = variable.barcode

			variable["date_of_death"] = variable["date_of_death"].to_time. strftime("%d/%b/%Y")
			if variable.cause_of_death.present?
				cause_of_death = variable.cause_of_death
				if cause_of_death.icd_10_1_reviewed.present?
					variable["icd_10_1"] = cause_of_death.icd_10_1_reviewed
				end

				if cause_of_death.icd_10_2_reviewed.present?
					variable["icd_10_2"] = cause_of_death.icd_10_2_reviewed
				end	

				if cause_of_death.icd_10_3_reviewed.present?
					variable["icd_10_3"] = cause_of_death.icd_10_3_reviewed
				end

				variable["final_code"] = cause_of_death.final_code
				if cause_of_death.final_code_reviewed.present?
					variable["final_code"] = cause_of_death.final_code_reviewed
				end

			end
			person_icd_codes = PersonICDCode.by_person_id.key(variable.id).first
			variable["supervisors_code"] = person_icd_codes.final_code_reviewed
			data << variable
		end
		render :text => data.to_json
	end

	def edit
		@person = Person.find(params[:id])
		
	end
end
