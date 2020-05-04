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
      person_icd_code = PersonICDCode.by_person_id.key(params[:id]).first
      total = 0
      score = 0
      i = 1

      causes_of_death = {}
      while i < 5
         break if params["icd_10_#{i}_reviewed"].blank?
         if params["icd_10_#{i}_decision"].to_i == 1
            causes_of_death["icd_10_#{i}_reviewed"] = params["icd_10_#{i}_reviewed"] 
            causes_of_death["reason_icd_10_#{i}_changed"] = nil
            score = score + 1
         else
            causes_of_death["icd_10_#{i}_reviewed"] = params["icd_10_#{i}_reviewed"]
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

      if (sample.sample.sort - sample.reviewed).count <= 0
        redirect_to "/sampled_cases"
      else
        redirect_to "/review/#{params[:sample_id]}?index=0"
      end

      
  end

  def save_cause_of_death
    @person = Person.find(params[:person_id])
    
    metric = {}
    
    metric["Second(s)"] = 1 
    metric["Minute(s)"] = 60
    metric["Hour(s)"]   = 360
    metric["Day(s)"]    = 60 * 60 * 24
    metric["Week(s)"]   = 60 * 60 * 24 * 7 
    metric["Month(s)"]  = 60 * 60 * 24 * 30

    params["onset_death_interval1"] = (params["onset_death_interval1"].to_i * metric[params["interval_unit1"]].to_i rescue nil)
    params["onset_death_interval2"] = (params["onset_death_interval2"].to_i * metric[params["interval_unit2"]].to_i rescue nil)
    params["onset_death_interval3"] = (params["onset_death_interval3"].to_i * metric[params["interval_unit3"]].to_i rescue nil)
    params["onset_death_interval4"] = (params["onset_death_interval4"].to_i * metric[params["interval_unit4"]].to_i rescue nil)
    
    #tobe revised
    params[:cause_of_death_conditions] = {}

   params[:other_significant_cause] = {} if params[:other_significant_cause].blank?

    params[:other_significant_cause] = (params[:other_significant_cause] rescue {}).delete_if { |key, value| value.to_s.strip == '' }

    params[:other_significant_cause].keys.each do |key|
      params[:cause_of_death_conditions][key] = {}
      params[:cause_of_death_conditions][key][:cause] = params[:other_significant_cause][key]
      params[:cause_of_death_conditions][key][:icd_code] = params[:other_significant_cause_icd_code][key]
    end
    if params[:record_action].blank? || params[:record_action] != "EDIT"
        params["coder"] = User.current_user.id
    end
    

    params["coded_at"] = Time.now
    person_icd_code = PersonICDCode.by_person_id.key(@person.id).first

    if person_icd_code.blank?
      person_icd_code = PersonICDCode.create({
                  :person_id => @person.id,
                  :tentative_code => params[:icd_10_code]  ,
                  :reason_tentative_differ_from_underlying => params[:reason_tentative_differ_from_underlying],
                  :final_code =>params[:final_icd_10_code],
                  :reason_final_differ_from_tentative => params[:reason_final_differ_from_tentative]
        })
    else
      person_icd_code.update_attributes({
                  :tentative_code => params[:icd_10_code]  ,
                  :reason_tentative_differ_from_underlying => params[:reason_tentative_differ_from_underlying],
                  :final_code =>params[:final_icd_10_code],
                  :reason_final_differ_from_tentative => params[:reason_final_differ_from_tentative]
        })
    end
    @person.update_attributes(params)

    coder_stat = CoderStat.by_coder_id.key(User.current_user.id).first
    if coder_stat.blank?
      CoderStat.create({
              coder_id: User.current_user.id, 
              number_of_records_coded: 1, 
              random_number: Random.rand(1..20),
              sampled: 0,
              reviewed: 0
      })    
    else
      random_number = coder_stat.random_number
      number_of_records_coded = coder_stat.number_of_records_coded.to_i + 1
      if (number_of_records_coded - random_number) % 20 == 0
          sample = ProficiencySample.by_coder_id.key(User.current_user.id).first
          if sample.blank?
            sample = ProficiencySample.new
            sample.coder_id = User.current_user.id
            sample.sample = [@person.id]
            sample.reviewed = []
            sample.save
          else
            sampled  = sample.sample
            sampled << @person.id
            sample.update_attributes({sample: sampled})          
          end
      end
      coder_stat.update_attributes({
                              number_of_records_coded: number_of_records_coded,
                              sampled: (coder_stat.sampled.to_i + 1)
                              })
    end

    flash[:success] = "Record updated successfully"
    redirect_to "/search?person_id=#{params[:person_id]}"
  end

  def cause_of_death
    @title = "Cause of death"
    @person = Person.find(params[:person_id])
    @place_of_death = place_of_death(@person)

    @person =  read_onset_death_interval(@person)
    if @person.status.blank?
        last_status = PersonRecordStatus.by_person_record_id.key(@person.id).each.sort_by{|d| d.created_at}.last
        
        states = {
                    "HQ ACTIVE" =>"HQ COMPLETE",
                    "HQ COMPLETE" => "MARKED HQ APPROVAL",
                    "MARKED HQ APPROVAL" => "MARKED HQ APPROVAL",
                    "HQ CAN PRINT" => "HQ PRINTED",
                    "HQ PRINTED" => "HQ DISPATCHED"
                 }
        if states[last_status.status].blank?
          PersonRecordStatus.change_status(@person, "HQ COMPLETE")
        else  
          PersonRecordStatus.change_status(@person, states[last_status.status])
        end
        
        
        redirect_to request.fullpath and return
    end
  end

  def cause_of_death_preview
    @person = Person.find(params[:person_id])
    @person_icd_code = PersonICDCode.by_person_id.key(@person.id).first
    @person = to_readable(@person)
  end

  def save_covid_record
    a = Covid.by_person_record_id.key(params[:id]).first
    a = Covid.new if a.blank?
    a.person_record_id = params[:id]
    a.test_result = params[:test_result]
    a.comment = params[:comment]
    a.other_data = {}
    a.save
    flash[:notice] = "COVID 19 Record saved"
    redirect_to "/show/#{params[:id]}?next_url=#{params[:next_url]}"
  end
  def show_covid_record
  end
end
