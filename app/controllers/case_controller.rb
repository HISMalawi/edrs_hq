class CaseController < ApplicationController
  before_filter :get_districts
  def open
    @title = "Open Cases"
    @statuses = ["HQ ACTIVE"]
    @page = 1
    session[:return_url] = request.path
    @drn_available = true
    render :template => "case/default"
  end

  def closed
    @title = "Closed Cases"
    @statuses = ["HQ CLOSED"]
    @page = 1
    @drn = true
    @dispatch = true

    @districts = []
    District.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
   
    session[:return_url] = request.path
    @available_printers = CONFIG["printer_name"].split(',')
    render :template => "case/default_batch"
  end

  def dispatched
    @title = "Dispatched Certificates"
    @statuses = ["HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def conflict
    @title = "Conflict Cases"
    @statuses = ["HQ CONFLICT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def hq_incomplete
    @title = "Reject Incomplete Cases"
    @statuses = ["HQ INCOMPLETE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_for_reprinting
    @title = "Approve for Reprinting"
    @statuses = ["DC REAPPROVED", "DC AMENDED", "DC REPRINT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def edited_from_dc
    @title = "Corrected from DC"
    @statuses = ["DC REAPPROVED"]
    @page = 1
    session[:return_url] = request.path
    render :template => "case/default"
  end

  def approve_potential_duplicates
    @title = "Approve Potential Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def resolve_duplicates
    @title = "Resolve duplicate cases"
    @statuses = ["HQ POTENTIAL DUPLICATE","HQ NOT DUPLICATE TBA"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def local_cases
    @title = "Local Cases"
    @statuses = ["-"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def remote_cases
    @title = "Remote Cases"
    @statuses = ["HQ REJECTED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_open_cases
    @title = "Re-open Cases"
    @statuses = ["HQ CLOSED", "HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ REAPPROVED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def rejected_and_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_for_printing
    @title = "Approve for Printing"
    @statuses = ["HQ COMPLETE"]
    @districts = []
    District.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_reprint
    @title = "Approve for Re-printing"
    @statuses = ["HQ COMPLETE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def incomplete_cases
    @title = "Incomplete Cases"
    @statuses = ["HQ INCOMPLETE TBA"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def rejected_cases
    @title = "Rejected Cases"
    @statuses = ["HQ CONFIRMED INCOMPLETE", "HQ REOPENED","HQ CAN REJECT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def print
    @title = "Print Certificates"
    @drn = true
    @statuses = ["HQ CAN PRINT","HQ CAN PRINT AMENDED","HQ CAN PRINT LOST","HQ CAN PRINT DAMAGED"]
    @districts = []
    District.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
    @page = 1
    session[:return_url] = request.path
    @available_printers = CONFIG["printer_name"].split(',')
    render :template => "case/default_batch"
  end

  def re_print
    @title = "Re-print Certificates"
    @statuses = ["HQ REPRINT"]
    @page = 1
    @drn = true
    session[:return_url] = request.path
    @available_printers = CONFIG["printer_name"].split(',')
    render :template => "case/default_batch"
  end

  def approved_for_print_marked_incomplete
    @title = "Marked incomplete but approved for print"

    @prev_statuses = ["HQ INCOMPLETE"]
    @statuses = ["HQ CAN PRINT"]

    @districts = []
    District.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end

    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def reprinted_certificates
    @title = "Re printed Certificates"
    @prev_status = "HQ REPRINT"
    @status = "HQ CLOSED"
    @statuses = ["HQ CLOSED","HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def ajax_change_status

    next_status = params[:next_status].gsub(/\-/, ' ') rescue nil
    render :text => "Error!" and return if next_status.blank?
    person = Person.find(params[:person_id])
    
    if ["HQ CAN PRINT", "HQ REPRINT", "HQ APPROVED", "HQ REAPPROVED"].include?(next_status)
      
      drn = PersonIdentifier.by_person_record_id_and_identifier_type.key([params[:person_id], "DEATH REGISTRATION NUMBER"]).last
      if drn.blank?
        last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
        job_interval = CONFIG['ben_assignment_interval']
        job_interval = 1.5 if job_interval.blank?
        job_interval = job_interval.to_f
        now = Time.now
        if (now - last_run_time).to_f > job_interval
          AssignDrn.perform_in(1)
        end

        if PersonRecordStatus.nextstatus.present?
           PersonRecordStatus.nextstatus[params[:person_id]] = next_status
        else
          PersonRecordStatus.nextstatus = {}
          PersonRecordStatus.nextstatus[params[:person_id]] = next_status
        end

        PersonRecordStatus.change_status(Person.find(params[:person_id]),"MARKED HQ APPROVAL")
        render :text => "ok" and return
      end
    end

    PersonRecordStatus.change_status(Person.find(params[:person_id]), next_status,params[:comment])

    if next_status == "HQ COMPLETE"
      @person = Person.find(params[:person_id])
      if ((search_similar_record(@person).count > 1) rescue false)

        status = PersonRecordStatus.by_person_recent_status.key(params[:person_id]).last
        status.voided  = true
        status.save

        PersonRecordStatus.create(
            :person_record_id => params[:person_id],
            :district_code => person.district_code,
            :prev_status => status.status,
            :creator => @current_user.id,
            :status => "HQ POTENTIAL DUPLICATE"
        )
      end
    end

    render :text => "ok" and return
  end

  def dispatch_printouts
    @title = "View Dispatch Printouts"
    @drn = true
    @statuses = ["HQ DISPATCHED"]
    session[:return_url] = request.path

    @page = 1

    render :template => "case/default"
  end

  def search_similar_record(params)
    people = []
    values = [
        params[:first_name].soundex,
        params[:last_name].soundex,
        params[:gender],
        params[:date_of_death],
        params[:birthdate],
        params[:place_of_death]]

    Person.by_demographics.key(values).each do |p|
      people << p if p.id != params.id
    end
    people
  end

  def void_cases
    @title = "Void Cases"
    @statuses = ["HQ CONFIRMED DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def voided_cases
    @title = "Voided Cases"
    @statuses = ["HQ VOIDED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def verify_cerfitificates
    @title = "Verify Certificates"
    @statuses = ["HQ PRINTED", "HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def potential
    @title = "Potential Duplicates"
    @statuses = ["HQ POTENTIAL DUPLICATE TBA"]
    @page = 1 
    session[:return_url] = request.path

    render :template => "case/default"
  end


  def can_confirm
    @title = "Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def confirmed
    @title = "Confirmed duplicates"
    @statuses = ["HQ CONFIRMED DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end


  def rejected_requests
    @title = "Rejected "
    @statuses = ["HQ AMEND REJECTED","HQ LOST REJECTED","HQ DAMAGED REJECTED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def amendment_requests
    @title = "Amendment request"
    if User.current_user.role =="Data Manager"
      @statuses = ["HQ AMEND GRANTED","HQ AMEND REJECTED TBA"]
    elsif  User.current_user.role =="Data Supervisor"
      @statuses = ["HQ AMEND"]
    else
      @statuses = ["HQ AMEND","HQ AMEND GRANTED"]
    end
    
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def reprint_requests
    @title = "Reprint request"
    if User.current_user.role =="Data Manager"
        @statuses = ["HQ LOST GRANTED","HQ DAMAGED REJECTED TBA"]
    elsif User.current_user.role =="Data Supervisor"
        @statuses = ["HQ LOST","HQ DAMAGED"]
    else
        @statuses = ["HQ LOST","HQ DAMAGED","HQ LOST GRANTED","HQ DAMAGED REJECTED TBA"]
    end
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def printed_amended_or_reprint
    @title = "Reprinted and amended Certificates"
    @prev_statuses = ["HQ AMEND","HQ DAMAGED","HQ LOST"]
    @statuses = ["HQ CAN PRINT","HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def more_open_cases

    cases = []
    
    if params[:district].present?
        district_code = District.by_name.key(params[:district]).first.id
        keys = []
        ((params[:statuses].split("|") rescue []) || []).each{|status|
          next if status.blank?
          keys << [ district_code,status.gsub(/\_/, " ").upcase]
        }
    
        (PersonRecordStatus.by_district_code_and_record_status.keys(keys).page(params[:page_number]).per(40) || []).each do |status|      
            person = status.person
            cases << fields_for_data_table(person)
        end 
    else
        keys = []
        ((params[:statuses].split("|") rescue []) || []).each{|status|
          next if status.blank?
          keys << status.gsub(/\_/, " ").upcase
        }
    
        (PersonRecordStatus.by_record_status.keys(keys).page(params[:page_number]).per(40) || []).each do |status|      
            person = status.person
            cases << fields_for_data_table(person)
        end 
    end
    render text: cases.to_json and return
  end

  def more_open_cases_with_prev_status


      sql = "SELECT c.person_record_id FROM person_record_status c INNER JOIN person_record_status p ON p.person_record_id = c.person_record_id
             WHERE c.status IN ('#{params[:statuses].split('|').join("','")}') AND p.status IN ('#{params[:prev_statuses].split('|').join("','")}') AND p.voided = 1 
             LIMIT 40 OFFSET #{(params[:page_number].to_i - 1) * 40}"

      connection = ActiveRecord::Base.connection
      data = connection.select_all(sql).as_json

      cases = []

      data.each do |row|
          person = Person.find(row["person_record_id"])
          cases << fields_for_data_table(person)
      end

      render text: cases.to_json and return
  end

  def fields_for_data_table(person)
      place_of_death = ""

      case person.place_of_death
      when "Home"
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
              place_of_death = person.place_of_death_village
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
              place_of_death = "#{place_of_death},#{person.place_of_death_district}"
          end
          if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
              place_of_death = "#{place_of_death},#{person.place_of_death_district}"
          end
      when "Health Facility"
          place_of_death = "#{person.hospital_of_death}, #{person.place_of_death_district}"
      else  
          place_of_death = "#{person.other_place_of_death}, #{person.place_of_death_district}"
      end

      if person.place_of_death && person.place_of_death.strip.downcase.include?("facility")
                 place_of_death = "#{person.hospital_of_death}, #{person.place_of_death_district}"
      elsif person.place_of_death_foreign && person.place_of_death_foreign.strip.downcase.include?("facility")
             if person.place_of_death_foreign_hospital.present? && person.place_of_death_foreign_hospital.to_s.length > 0
                place_of_death  = person.place_of_death_foreign_hospital
             end
              
             if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death},#{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death},#{person.place_of_death_country}"
                end
                 
             end
      elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Home"

              if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
                 place_of_death = person.place_of_death_foreign_village
              end

              if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
                 place_of_death = "#{place_of_death},#{person.place_of_death_foreign_district}"
              end

              if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
                 place_of_death = "#{place_of_death},#{person.place_of_death_foreign_state}"
              end

              if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death},#{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death},#{person.place_of_death_country}"
                end
                 
              end
        elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Other"
               if person.other_place_of_death.present? && person.other_place_of_death.to_s.length > 0
                 place_of_death = person.other_place_of_death
              end

              if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
                 place_of_death = "#{place_of_death},#{person.place_of_death_foreign_village}"
              end

              if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
                 place_of_death = "#{place_of_death},#{person.place_of_death_foreign_district}"
              end

              if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
                 place_of_death = "#{place_of_death},#{person.place_of_death_foreign_state}"
              end

              if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death},#{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death},#{person.place_of_death_country}"
                end
                 
              end

      elsif person.place_of_death  && person.place_of_death =="Other"
                 place_of_death  = person.other_place_of_death;

      elsif person.place_of_death  && person.place_of_death =="Home"
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
              place_of_death = person.place_of_death_village
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
              place_of_death = "#{place_of_death},#{person.place_of_death_district}"
          end
          if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
              place_of_death = "#{place_of_death},#{person.place_of_death_district}"
          end

      end

      return {
          drn: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH REGISTRATION NUMBER"]).last.identifier rescue nil),
          den: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH ENTRY NUMBER"]).last.identifier rescue nil),
          name: "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name}",
          gender:     person.gender,
          dob:        person.birthdate.strftime("%d/%b/%Y"),
          dod:        person.date_of_death.strftime("%d/%b/%Y"),
          place_of_death: place_of_death,
          person_id:  person.id
        }
  end

  def more_amended_or_reprinted_cases   
    cases = []
    
    (PersonRecordStatus.by_amend_or_reprint.page(params[:page_number]).per(10) || []).each do |status|   
      person = status.person
      cases << fields_for_data_table(person)
    end 

    render text: cases.to_json and return
  end

  def special_cases
      @title = params[:registration_type].humanize
      @statuses = ["DC AMENDED"]
      @page = 1
      session[:return_url] = request.path
      render :template => "case/default"
  end
  def more_special_cases
     cases = []
    (Person.by_registration_type.key(params[:registration_type]).page(params[:page_number]).per(10) || []).each do |person|
      cases << fields_for_data_table(person) if person.den.present?
    end 

    render text: cases.to_json and return
  end

  def show

    @person = Person.find(params[:person_id])
    begin
        @person.save
        PersonRecordStatus.by_person_recent_status.key(params[:id]).last.save
    rescue Exception => e
      
    end

    if  ["HQ POTENTIAL DUPLICATE TBA","HQ NOT DUPLICATE TBA","HQ POTENTIAL DUPLICATE","HQ DUPLICATE"].include? @person.status 
        redirect_to "/duplicate/#{@person.id}?index=0"
    elsif ['HQ-AMEND','HQ-AMEND-GRANTED','HQ-AMEND-REJECTED'].include? @status 
        redirect_to "/person/ammend_case?id=#{@person.id}"
    end

    if SETTINGS["potential_duplicate"]
          record = {}
          record["first_name"] = @person.first_name
          record["last_name"] = @person.last_name
          record["middle_name"] = (@person.middle_name rescue nil)
          record["gender"] = @person.gender
          record["place_of_death_district"] = @person.place_of_death_district
          record["birthdate"] = @person.birthdate
          record["date_of_death"] = @person.date_of_death
          record["mother_last_name"] = (@person.mother_last_name rescue nil)
          record["mother_middle_name"] = (@person.mother_middle_name rescue nil)
          record["mother_first_name"] = (@person.mother_first_name rescue nil)
          record["father_last_name"] = (@person.father_last_name rescue nil)
          record["father_middle_name"] = (@person.father_middle_name rescue nil)
          record["father_first_name"] = (@person.father_first_name rescue nil)
          record["id"] = @person.id
          record["district_code"] = @person.district_code
          SimpleElasticSearch.add(record)

          if @person.status =="HQ POTENTIAL DUPLICATE TBA"
            
          end
          @results = []
          if @person.status == "HQ ACTIVE"
                        
            duplicates = SimpleElasticSearch.query_duplicate_coded(record,SETTINGS['duplicate_precision'])
            
            @results = duplicates

            duplicate_ids = duplicates.collect{|d| d["_id"] if Person.find(d["_id"]).present? }

            if duplicate_ids.present?
              change_log = [{:duplicates => duplicate_ids.join("|")}]
              Audit.create({
                              :record_id  => @person.id.to_s,
                              :audit_type => "POTENTIAL DUPLICATE",
                              :reason     => "Record is a potential",
                              :change_log => change_log
              })

              PersonRecordStatus.change_status(@person,"HQ POTENTIAL DUPLICATE TBA")
            else
            end
          end

    end

    #raise PersonRecordStatus.by_person_recent_status.key(@person.id).last.status.inspect
    @statuses = [PersonRecordStatus.by_person_recent_status.key(@person.id).last.status]

    @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last
    

    @person_place_details = place_details(@person)

    if @person.status == "DC REAPPROVED"
            @next_state ={
                "Data Checking Clerk" => ["HQ COMPLETE", "HQ INCOMPLETE TBA"],
                "Data Supervisor" => ["HQ COMPLETE", "HQ INCOMPLETE"],
                "Data Manager" => ["HQ CAN PRINT", "HQ CONFIRMED INCOMPLETE"]
            }
    else
          @next_state ={
                "Data Checking Clerk" => ["HQ COMPLETE", "HQ INCOMPLETE TBA"],
                "Data Supervisor" => ["HQ CONFLICT", "HQ INCOMPLETE"],
                "Data Manager" => ["HQ CAN PRINT", "HQ CONFIRMED INCOMPLETE"]
            }
    end

    @place_of_death = place_of_death(@person)
    @available_printers = YAML.load_file("#{Rails.root}/config/couchdb.yml")[Rails.env]['printer_name'].split(',') rescue []
    
    @tasks = ActionMatrix.read(@current_user.role, @statuses)
  end

  def show_duplicate
      @person = Person.find(params[:id])

      @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

      @person_place_details = place_details(@person)

      @existing_record = []

      @existing_ids = ""
      @duplicates_audit = Audit.by_record_id_and_audit_type.key([@person.id.to_s, "POTENTIAL DUPLICATE"]).first
      @statuses = []
      @duplicates_audit.change_log.each do |log|
        unless  log['duplicates'].blank?
          @existing_ids = log['duplicates']
          ids = log['duplicates'].split("|")
          ids.each do |id|
             @existing_record << id
             @statuses << PersonRecordStatus.by_person_recent_status.key(id).last.status
          end
        end
      end
      @existing_record = @existing_record.sort
      @statuses = @statuses.join("|")
     
      @tasks = ActionMatrix.read(@current_user.role, [@person.status])

      @title = "Resolve Duplicate"
  end

  def find
      person = Person.find(params[:id])
      person["status"] = PersonRecordStatus.by_person_recent_status.key(params[:id]).last.status
      render :text => person_selective_fields(person).to_json
  end

  def person_selective_fields(person)

      den = PersonIdentifier.by_person_record_id_and_identifier_type.key([person.id,"DEATH ENTRY NUMBER"]).first

      return {
                      id: person.id,
                      first_name: person.first_name, 
                      last_name: person.last_name ,
                      middle_name:  (person.middle_name rescue ""),
                      gender: person.gender,
                      birthdate: person.birthdate,
                      date_of_death: person.date_of_death,
                      place_of_death: person.place_of_death,
                      hospital_of_death:(person.hospital_of_death rescue ""),
                      other_place_of_death: person.other_place_of_death,
                      place_of_death_village: (person.place_of_death_village rescue ""),
                      place_of_death_ta: (person.place_of_death_ta rescue ""),
                      place_of_death_district: (person.place_of_death_district rescue ""),
                      mother_first_name: person.mother_first_name,
                      mother_last_name: person.mother_last_name,
                      mother_middle_name: person.mother_middle_name,
                      father_first_name: person.father_first_name,
                      father_last_name: person.father_last_name,
                      father_middle_name: person.father_middle_name,
                      informant_first_name: person.informant_first_name,
                      informant_last_name: person.informant_last_name,
                      informant_middle_name: person.informant_middle_name,
                      home_village: (person.home_village  rescue ""),
                      home_ta:  (person.home_ta rescue ""),
                      home_district: (person.home_district rescue ""),
                      home_country:  ( person.home_country rescue ""),
                      current_village: (person.current_village  rescue ""),
                      current_ta:  (person.current_ta rescue ""),
                      current_district: (person.current_district rescue ""),
                      current_country:  ( person.current_country rescue ""),
                      den: (den.identifier rescue ""),
                      status: (person.status),
                      nationality: person.nationality
                     }
  end

  def get_districts
    @districts = []
    District.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
  end
end
