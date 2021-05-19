class CaseController < ApplicationController
  before_filter :get_districts, :set_next_status

  def set_next_status

      @next_state ={
          "Data Verifier" => ["HQ COMPLETE", "HQ INCOMPLETE TBA"],
          "Data Supervisor" => ["HQ CONFLICT", "HQ INCOMPLETE"],
          "Data Manager" => ["HQ CAN PRINT", "HQ CONFIRMED INCOMPLETE"]
      }
  end
  def save_barcode
    person = Person.find(params[:id])
    barcode = PersonIdentifier.new
    barcode.person_record_id = person.id
    barcode.identifier = params[:barcode]
    barcode.identifier_type = "Form Barcode"
    barcode.creator = (User.current_user.id rescue (@current_user.id rescue nil))
    barcode.district_code = (person.district_code rescue CONFIG['district_code'])
    if barcode.save
        render :text => "saved"
    else
        render :text => "error"
    end
  end
  def user_action(role, status)
      action = false
      if role =="Data Verifier" && status == "HQ ACTIVE"
          action = true
      end
      if role =="Data Manager" && ["HQ COMPLETE", "HQ CAN PRINT"].include?(status)
          action = true
      end
      if role =="Data Supervisor" && ["HQ INCOMPLETE TBA"].include?(status)
          action = true
      end
      return action
  end
  def open
    @title = "Open Cases"
    @statuses = ["HQ ACTIVE"]
    @page = 0
    session[:return_url] = request.path
    @drn = false
    @enable_action = user_action(User.current_user.role, @statuses.first)
    render :template => "case/default"
  end

  def closed
    @title = "Printed Cases"
    @statuses = ["HQ PRINTED", "DC PRINTED"]
    @page = 0
    @drn = true
    @dispatch = true
    @batch = true
    @districts = []
    DistrictRecord.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
   
    session[:return_url] = request.path
    @available_printers = SETTINGS["printer_name"].split(',')
    render :template => "case/default_batch"
  end

  def dc_printed
    @title = "Printed Cases"
    @statuses = ["DC PRINTED"]
    @page = 0
    @drn = true
    @dispatch = true

    @districts = []
    DistrictRecord.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
    @batch = true
    session[:return_url] = request.path
    @available_printers = SETTINGS["printer_name"].split(',')
    render :template => "case/default"    
  end

  def hq_printed
    @title = "Printed Cases"
    @statuses = ["HQ PRINTED"]
    @page = 0
    @drn = true
    @dispatch = true
    @batch = true
    @districts = []
    DistrictRecord.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
   
    session[:return_url] = request.path
    @available_printers = SETTINGS["printer_name"].split(',')
    render :template => "case/default"    
  end

  def dispatched
    @title = "Dispatched Certificates"
    @statuses = ["HQ DISPATCHED"]
    @drn = true
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def conflict
    @title = "Conflict Cases"
    @statuses = ["HQ CONFLICT"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def hq_incomplete
    @title = "Reject Incomplete Cases"
    @statuses = ["HQ INCOMPLETE"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_for_reprinting
    @title = "Approve for Reprinting"
    @statuses = ["DC REAPPROVED", "DC AMENDED", "DC REPRINT"]
    @page = 0
    session[:return_url] = request.path
    @enable_action = user_action(User.current_user.role, @statuses.first)
    render :template => "case/default"
  end

  def edited_from_dc
    @title = "Corrected from DC"
    @statuses = ["DC REAPPROVED"]
    @page = 0
    session[:return_url] = request.path
    render :template => "case/default"
  end

  def approve_potential_duplicates
    @title = "Approve Potential Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def resolve_duplicates
    @title = "Resolve duplicate cases"
    @statuses = ["HQ POTENTIAL DUPLICATE","HQ NOT DUPLICATE"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approved_duplicate
    @title = "Approved duplicates"
    @prev_statuses = ["HQ POTENTIAL DUPLICATE TBA","HQ NOT DUPLICATE TBA","HQ POTENTIAL DUPLICATE","HQ DUPLICATE"]
    @page = 0
    @statuses = ["HQ CAN PRINT"]
    session[:return_url] = request.path
    render :template => "case/default"
  end

  def local_cases
    @title = "Local Cases"
    @statuses = ["-"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def remote_cases
    @title = "Remote Cases"
    @statuses = ["HQ REJECTED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_open_cases
    @title = "Re-open Cases"
    @statuses = ["HQ PRINTED", "HQ DISPATCHED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ REAPPROVED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def rejected_and_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_for_printing
    @title = "Approve for Printing"
    @statuses = ["HQ COMPLETE"]
    @districts = []
    @enable_action = user_action(User.current_user.role, @statuses.first)
    @next_state ={
              "Data Verifier" => ["HQ COMPLETE", "HQ INCOMPLETE TBA"],
              "Data Supervisor" => ["HQ CONFLICT", "HQ INCOMPLETE"],
              "Data Manager" => ["HQ CAN PRINT", "HQ CONFIRMED INCOMPLETE"]
          }
  
    DistrictRecord.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
    @districts = @districts.sort
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_reprint
    @title = "Approve for Re-printing"
    @statuses = ["HQ RE PRINT"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def incomplete_cases
    @title = "Incomplete Cases"
    @statuses = ["HQ INCOMPLETE TBA"]
    @page = 0
    @enable_action = user_action(User.current_user.role, @statuses.first)
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def rejected_cases
    @title = "Rejected Cases"
    @statuses = ["HQ CONFIRMED INCOMPLETE", "HQ REOPENED","HQ CAN REJECT"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def print
    @title = "Print Certificates"
    @drn = true
    @statuses = ["HQ CAN PRINT","HQ CAN PRINT AMENDED","HQ CAN PRINT LOST","HQ CAN PRINT DAMAGED"]
    @districts = []
    DistrictRecord.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
    @page = 0
    session[:return_url] = request.path
    @available_printers = SETTINGS["printer_name"].split(',')
    @batch = true
    render :template => "case/default"
  end

  def re_print
    @title = "Re-print Certificates"
    @statuses = ["HQ CAN RE PRINT"]
    @page = 0
    @drn = true
    session[:return_url] = request.path
    @available_printers = SETTINGS["printer_name"].split(',')
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

    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def reprinted_certificates
    @title = "Re printed Certificates"
    @prev_statuses = ["HQ CAN RE PRINT"]
    @status = "HQ PRINTED"
    @statuses = ["HQ PRINTED","HQ DISPATCHED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def ajax_change_status
    
    next_status = params[:next_status].gsub(/\-/, ' ') rescue nil

    render :text => "Error!" and return if next_status.blank?
    person = Record.find(params[:person_id])
    
    if ["HQ CAN PRINT", "HQ RE PRINT", "HQ APPROVED", "HQ REAPPROVED"].include?(next_status)
        RecordIdentifier.assign_drn(person,User.current_user.id)
        #RecordStatus.change_status(person,"MARKED HQ APPROVAL",(params[:comment].present? ? params[:comment] : nil))
        RecordStatus.change_status(person,next_status,(params[:comment].present? ? params[:comment] : nil))
        render :text => "ok" and return
    end

    comment = params[:comment]
    comment = "Marked as complete" if next_status == "HQ COMPLETE"
   
    

    if next_status == "HQ COMPLETE"
      @person = Record.find(params[:person_id])
      if ((search_similar_record(@person).count > 1) rescue false)

        status = RecordStatus.where(person_record_id: params[:person_id]).order(:created_at).last
        status.voided  = 1
        status.save

        RecordStatus.create(
            :person_record_id => params[:person_id],
            :district_code => person.district_code,
            :prev_status => status.status,
            :creator => @current_user.id,
            :comment =>(params[:comment].present? ? params[:comment] : nil),
            :status => "HQ POTENTIAL DUPLICATE TBA"
        )
      end
    end
    if next_status == "HQ DUPLICATE"
        
    end

    RecordStatus.change_status(person, next_status,comment)

    render :text => "ok" and return
  end

  def dispatch_printouts
    @title = "View Dispatch Printouts"
    @drn = true
    @statuses = ["HQ DISPATCHED"]
    session[:return_url] = request.path

    @page = 0

    render :template => "case/default"
  end

  def verify_certificates
    @title = "Printed Certificates"
    @drn = true
    @statuses = ["HQ PRINTED","HQ DISPATCHED"]
    session[:return_url] = request.path

    @page = 0

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
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def voided_cases
    @title = "Voided Cases"
    @statuses = ["HQ VOIDED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def verify_cerfitificates
    @title = "Verify Certificates"
    @statuses = ["HQ PRINTED", "HQ DISPATCHED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def potential
    @title = "Potential Duplicates"
    @statuses = ["HQ POTENTIAL DUPLICATE TBA"]
    @page = 0 
    session[:return_url] = request.path

    render :template => "case/default"
  end


  def can_confirm
    @title = "Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def confirmed
    @title = "Confirmed duplicates"
    @statuses = ["HQ CONFIRMED DUPLICATE"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end


  def rejected_requests
    @title = "Rejected "
    @statuses = ["HQ AMEND REJECTED","HQ LOST REJECTED","HQ DAMAGED REJECTED"]
    @page = 0
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
    
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def view_stats
    redirect_to "/" and return if params[:stat].blank?
    @title = params[:stat]

    cummulatives_keys = {}
    cummulatives_keys["Newly Received"] = ["HQ ACTIVE"]
    cummulatives_keys["Verified by DV"] = ["HQ COMPLETE"]
    cummulatives_keys["Marked incomplete by DV"] = ["HQ INCOMPLETE TBA"]
    cummulatives_keys["Incomplete Records"]  = ["HQ INCOMPLETE"]
    cummulatives_keys["Conflict cases"] = ["HQ CONFLICT"]
    cummulatives_keys["Can reject to DC"] = ["HQ CAN REJECT"]
    cummulatives_keys["Print Queue"] = ["HQ CAN PRINT"]
    cummulatives_keys["Re pritnt- Queue"] = ["HQ REPRINT","HQ REPRINT REQUEST"]
    cummulatives_keys["Suspected duplicates"] = ["HQ POTENTIAL DUPLICATE","HQ DUPLICATE"]
    cummulatives_keys["Printed"] = ["HQ PRINTED"]
    cummulatives_keys["Dispatched"] =  ["HQ DISPATCHED"]

    @statuses = cummulatives_keys[@title]
    @page = 0
    session[:return_url] = request.path

    @available_printers = SETTINGS["printer_name"].split(',')

    if @title == "Print Queue" || @title == "Printed"
        if @title == "Printed"
            @dispatch = true
        end
        render :template => "case/default_batch"
    else
        render :template => "case/default"     
    end
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
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def printed_amended_or_reprint
    @title = "Reprinted and amended Certificates"
    @prev_statuses = ["HQ AMEND","HQ DAMAGED","HQ LOST"]
    @statuses = ["HQ CAN PRINT","HQ DISPATCHED"]
    @page = 0
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def more_open_cases_back
    cases = []
    offset = params[:page_number].to_i * 40
    district_code_query = (params[:district].present? ? "AND district_code ='#{DistrictRecord.where(name:params[:district]).first.id}'" : "")

    sql = "SELECT person_record_id, status FROM person_record_status WHERE voided = 0 AND status 
          IN ('#{params[:statuses].collect{|status| status.gsub(/\_/, " ").upcase}.join("','")}') #{district_code_query}
           LIMIT 200 OFFSET #{offset}"

    connection = ActiveRecord::Base.connection
    data = connection.select_all(sql).as_json

    cases = []

    data.each do |row|
          person = Record.find(row["person_record_id"])
          next if person.blank?
          next if person.first_name.blank?  && person.last_name.blank?
          cases << fields_for_data_table(person)
    end

    render text: cases.to_json and return
   
  end

  def more_open_cases
    cases = []
    page = (params[:start].to_i / params[:length].to_i)
    offset = page * params[:length].to_i
    district_code_query = (params[:district].present? ? "AND p.district_code ='#{DistrictRecord.where(name:params[:district]).first.id}'" : "")
    
    search_val = params[:search][:value] rescue nil
    if search_val.present?
        search_query = "AND (p.first_name LIKE '%#{search_val}%' || 
                        p.last_name LIKE '%#{search_val}%' || p.middle_name LIKE '%#{search_val}%' 
                        || p.hospital_of_death LIKE '%#{search_val}%' || p.gender LIKE '%#{search_val}%' 
                        || p.place_of_death_ta LIKE '%#{search_val}%' || p.place_of_death_village LIKE '%#{search_val}%' 
                        || p.place_of_death_district LIKE '%#{search_val}%' || i.identifier LIKE '%#{search_val}%')"
    else
      search_query = ""
    end

    sql = "SELECT person_id, status FROM person_record_status s INNER JOIN people p ON s.person_record_id = p.person_id 
           INNER JOIN person_identifier i ON i.person_record_id = p.person_id
           WHERE i.identifier_type='DEATH ENTRY NUMBER' AND s.voided = 0 AND status IN ('#{params[:statuses].collect{|status| status.gsub(/\_/, " ").upcase}.join("','")}') 
           #{search_query} #{district_code_query}"
 
    sql =  "#{sql} LIMIT #{params[:length].to_i} OFFSET #{offset}"

    connection = ActiveRecord::Base.connection
    data = connection.select_all(sql).as_json

    cases = []
    records = {}
    data.each do |row|
          person = Record.find(row["person_id"])
          next if person.blank?
          next if person.first_name.blank?  && person.last_name.blank?
          records[person.id] = person_selective_fields(person)
          cases << data_table_entry(person,params[:drn])
    end
    sql = "SELECT COUNT(distinct person_record_id) as total FROM person_record_status WHERE voided = 0 AND status 
          IN ('#{params[:statuses].collect{|status| status.gsub(/\_/, " ").upcase}.join("','")}') #{district_code_query}"
    
    total = connection.select_all(sql).as_json.last["total"].to_i rescue 0
    render :text => {
          "draw" => params[:draw].to_i,
          "recordsTotal" => total,
          "recordsFiltered" => total,
          "records" => records,
          "data" => cases}.to_json and return

    #render text: cases.to_json and return
   
  end

  def more_open_cases_with_prev_status

      offset = params[:page_number].to_i * 40
      sql = "SELECT c.person_record_id FROM person_record_status c INNER JOIN person_record_status p ON p.person_record_id = c.person_record_id
             WHERE c.status IN ('#{params[:statuses].join("','")}') AND p.status IN ('#{params[:prev_statuses].join("','")}') AND p.voided = 1 
             LIMIT 40 OFFSET #{offset}"

      connection = ActiveRecord::Base.connection
      data = connection.select_all(sql).as_json

      cases = []

      data.each do |row|
          person = Record.find(row["person_record_id"])
          cases << fields_for_data_table(person)
      end

      render text: cases.to_json and return
  end
  def data_table_entry(person, drn=false)
     row = []
    
     if drn.present? && drn=="true"
        row << person.drn
     end
       row = row + [person.den,
                    "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name} (#{person.gender.first})",
                    person.birthdate.strftime("%d/%b/%Y"),
                    person.date_of_death.strftime("%d/%b/%Y"),
                    place_of_death(person), 
                    person.id]
  end
  def fields_for_data_table(person)

    begin

        a = {
          drn: (person.drn rescue nil),
          den: (person.den rescue nil),
          name: "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name}",
          gender:     person.gender,
          dob:        person.birthdate.strftime("%d/%b/%Y"),
          dod:        person.date_of_death.strftime("%d/%b/%Y"),
          place_of_death: place_of_death(person),
          person_id:  person.id
        }     
    rescue Exception => e
       raise person.id
    end

    return a
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
      @statuses = []
      @page = 0
      session[:return_url] = request.path
      render :template => "case/default"
  end


  def more_special_cases
    cases = []
    offset = params[:page_number].to_i * 40
    district_code_query = (params[:district].present? ? "AND district_code ='#{DistrictRecord.where(name:params[:district]).first.id}'" : "")
    (Record.where("registration_type = '#{params[:registration_type]}' #{district_code_query}").offset(offset).limit(40) || []).each do |person|
          cases << fields_for_data_table(person) if person.den.present?
        end 
    render text: cases.to_json and return
  end

  def printed_special_case
     @title = "Printed Special Cases"
     @statuses = ["HQ PRINTED"]
     @registration_types = ["Abnormal Deaths","Dead on Arrival","Unclaimed bodies","Missing Person","Deaths Abroad"]
     @page = 0
     session[:return_url] = request.path
     render :template => "case/default"
  end

  def rejected_special_case
     @title = "Printed Special Cases"
     @statuses = ["HQ REJECTED"]
     @registration_types = ["Abnormal Deaths","Dead on Arrival","Unclaimed bodies","Missing Person","Deaths Abroad"]
     @page = 0
     session[:return_url] = request.path
     render :template => "case/default"
  end

  def more_special_cases_by_status
      keys = []
      cases = []
      if params[:district].present?
        district_code = District.by_name.key(params[:district]).first.id
        params[:statuses].split("|").each do |status|
            params[:registration_types].split("|").each do |type|
                keys << [type,district_code,status]
            end  
        end
        
        (PersonRecordStatus.by_registration_type_and_district_code_and_status.keys(keys).page(params[:page_number]).per(10) || []).each do |status|
          person = status.person
          cases << fields_for_data_table(person) if person.den.present?
        end 
      else
        params[:statuses].split("|").each do |status|
            params[:registration_types].split("|").each do |type|
                keys << [type,status]
            end  
        end
        (PersonRecordStatus.by_registration_type_and_status.keys(keys).page(params[:page_number]).per(10) || []).each do |status|
          person = status.person
          cases << fields_for_data_table(person) if person.den.present?
        end 
      end
      render text: cases.to_json and return
  end

  def unlock_record
      lock = MyLock.find(params[:lock_id]) rescue nil
 
      if lock.present?
        if lock.user_id == User.current_user.id
          lock.destroy
        end
      end
      redirect_to params[:next_url]
  end

  def show

    @person = Record.find(params[:person_id])
    @results = []
    if @person.blank?
      @person = Person.find(params[:person_id])

      begin
          @person.save
          PersonRecordStatus.by_person_recent_status.key(params[:id]).last.save
      rescue Exception => e
        
      end
    end

    if  ["HQ POTENTIAL DUPLICATE TBA","HQ NOT DUPLICATE TBA","HQ POTENTIAL DUPLICATE","HQ DUPLICATE"].include? @person.status 
        redirect_to "/duplicate/#{@person.id}?index=0"
    elsif ['HQ-AMEND','HQ-AMEND-GRANTED','HQ-AMEND-REJECTED'].include? @status 
        redirect_to "/person/ammend_case?id=#{@person.id}"
    end

    @locked = false

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
         
          if @person.status == "HQ ACTIVE"
                        
            duplicates = SimpleElasticSearch.query_duplicate_coded(record,SETTINGS['duplicate_precision']) rescue []
            
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

              RecordStatus.change_status(@person,"HQ POTENTIAL DUPLICATE TBA")
            else
            end
          end

    end

    #raise PersonRecordStatus.by_person_recent_status.key(@person.id).last.status.inspect
  
    @status = RecordStatus.where(person_record_id: @person.id, voided: 0).last rescue nil

    if @status.blank?
      @status = RecordStatus.where(person_record_id: @person.id).order(:created_at).last
    else
      @status = RecordStatus.where(person_record_id: @person.id, voided: 0).last rescue nil
    end

       
    if params[:status].present?
        if @status.status.to_s.squish != params[:status].squish
          (RecordStatus.where(person_record_id: @person.id, status: params[:status]) rescue [] ).each do |state|
              state.voided = 1
              state.save
          end
        end
    end
    @statuses = [(@status.status rescue nil)]

    if @status ="HQ PRINTED"
        @dispatch = true 
    end

    @person_place_details = place_details(@person)

    if @person.status == "DC REAPPROVED"
            @next_state ={
                "Data Verifier" => ["HQ COMPLETE", "HQ INCOMPLETE TBA"],
                "Data Supervisor" => ["HQ COMPLETE", "HQ INCOMPLETE"],
                "Data Manager" => ["HQ CAN PRINT", "HQ CONFIRMED INCOMPLETE"]
            }
    else
          @next_state ={
                "Data Verifier" => ["HQ COMPLETE", "HQ INCOMPLETE TBA"],
                "Data Supervisor" => ["HQ CONFLICT", "HQ INCOMPLETE"],
                "Data Manager" => ["HQ CAN PRINT", "HQ CONFIRMED INCOMPLETE"]
            }
    end

    @place_of_death = place_of_death(@person)
    @available_printers = SETTINGS["printer_name"].split(',') rescue []
    
    @tasks = ActionMatrix.read(@current_user.role, @statuses)
    @covid = Covid.by_person_record_id.key(params[:person_id]).first
  end

  def show_duplicate
      @person = Record.find(params[:id])

      @status = RecordStatus.where(person_record_id: params[:id]).last

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
  def view_certificate
    
  end

  def pdf_certificate
      pdf_filename = "#{SETTINGS['certificates_path']}#{params[:id]}.pdf"

      if !File.exist?(pdf_filename)
          paper_size = GlobalProperty.find("paper_size").value rescue "A4"
    
          if paper_size == "A4"
             zoom = 0.83
          elsif paper_size == "A5"
             zoom = 0.6
          end

          output_file = "#{SETTINGS['certificates_path']}#{params[:id]}.pdf"

          input_url = "#{CONFIG["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/death_certificate/#{params[:id]}"

          Kernel.system "#{SETTINGS['wkhtmltopdf']} --zoom #{zoom} --page-size #{paper_size} #{input_url} #{output_file}"
          #PDFKit.new(input_url, :page_size => paper_size, :zoom => zoom).to_file(output_file)

          sleep(2)
          redirect_to request.fullpath and return
      end
      send_file(pdf_filename, :filename => "#{params[:id]}.pdf", :disposition => 'inline', :type => "application/pdf")
  end
  
  def find
      person = Person.find(params[:id])
      person["status"] = RecordStatus.where(person_record_id:params[:id]).last.status
      render :text => person_selective_fields(person).to_json
  end

  def person_selective_fields(person)
      den = RecordIdentifier.where(person_record_id: person.id,identifier_type:"DEATH ENTRY NUMBER").first

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
                      den: (person.den rescue ""),
                      status: (person.status),
                      death_place: place_of_death(person),
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
