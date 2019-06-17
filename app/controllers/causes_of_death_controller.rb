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

	def view_ccu_dispatch
	    @ccu_dispatch = (CauseOfDeathDispatch.all || [])
	end

	def view_ccu_confirmed_dispatch
     @ccu_dispatch = (CauseOfDeathDispatch.by_reviewed.key(true) || [])
    end
  	def save_review
  	  raise params.inspect
      person_icd_code = PersonICDCode.by_person_id.key(params[:id]).first
      total = 0
      score = 0
      i = 1

      causes_of_death = {}
      while i < 5

         break if params["icd_10_#{i}_reviewed"].blank?
         if params["icd_10_#{i}_reviewed"]["result"].to_i == 1

            causes_of_death["icd_10_#{i}_reviewed"] = params["icd_10_#{i}_reviewed"]["code"] 
            causes_of_death["reason_icd_10_#{i}_changed"] = nil
            score = score + 1
         else
            causes_of_death["icd_10_#{i}_reviewed"] = params["icd_10_#{i}_reviewed"]["code"] 
            causes_of_death["reason_icd_10_#{i}_changed"] = params["reason_icd_10_#{i}_changed"]          
         end
         total = total + 1
         i = i + 1
      end

      person_icd_code.update_attributes(causes_of_death)
      other_significant_causes = {}

      j = 1

      while j < 10
        break if params["icd_10_#{j}i_reviewed"].blank?
        other_significant_causes[j] = {}
        if params["icd_10_#{j}i_reviewed"]["result"].to_i == 1
          other_significant_causes[j]["icd_code"] = params["icd_10_#{j}i_reviewed"]["code"]
            score = score + 1
        else
          other_significant_causes[j]["icd_code"] = params["icd_10_#{j}i_reviewed"]["code"]
          other_significant_causes[j]["reason"] = params["reason_icd_10_#{j}i_changed"]
        end
        total = total + 1
        j = j + 1
      end

      
      person_icd_code.update_attributes({
                        :other_significant_causes => other_significant_causes, 
                        :review_results =>"#{(score/total.to_f) * 100}",
                        :tentative_code_reviewed => params[:tentative_code_reviewed],
                        :reason_tentative_code_changed => params[:reason_tentative_code_changed],
                        :final_code_reviewed => params[:final_code_reviewed],
                        :reason_final_code_changed => params[:reason_final_code_changed]})

      sample = ProficiencySample.find(params[:sample_id])

      reviewed = sample.reviewed

      reviewed << params[:id]

      sample.update_attributes({reviewed: reviewed.uniq})

      render :text => "ok"
  end
end
