class HqController < ApplicationController
  def dashboard

    @icoFolder = nil

    @section = "Home"

    @targeturl = "/"

    @targettext = "Logout"

    @user = User.find_by_username(session[:current_user_id])

    @districts = {}

    District.all.each do |district|

      @districts[district.id] = district.name

    end
  end

  def search
    @title = "Search Death Records"
  end

  def do_search
    results = []
    @title = "Search Results"
    @statuses = []

    case params[:search_type]
      when "barcode"
          PersonIdentifier.by_identifier_and_identifier_type.key([params[:barcode], "Form Barcode"]).each do |identifier|
          results << identifier.person
        end
      when "den"
        PersonIdentifier.by_identifier_and_identifier_type.key([params[:den], "DEATH ENTRY NUMBER"]).each do |identifier|
          results << identifier.person
        end
      when "drn"
        PersonIdentifier.by_identifier_and_identifier_type.key([params[:den], "DEATH REGISTRATION NUMBER"]).each do |identifier|
          results << identifier.person
        end
      when "details_of_deceased"
        last_name = params[:last_name].encrypt
        first_name = params[:first_name].encrypt
        gender = params[:gender]
        results = Person.by_last_name_and_first_name_and_gender.key([last_name, first_name, gender]);
      when "home_address"
        if params[:home_country] != "Malawian"
          home_country_id = Nationality.by_name(params[:home_country]).last.id rescue nil
          results = Person.by_home_country_id.key(home_country_id)
        else
          home_district_id = District.by_name.key(params[:home_district]).last.id rescue nil
          home_ta_id = TraditionalAuthority.by_district_id_and_name.key([home_district_id, params[:home_ta]]).last.id rescue nil
          home_village_id = Village.by_ta_id_and_name.key([home_ta_id, params[:home_village]]).last.id rescue nil
          results = Person.by_home_village_id.key(home_village_id)
        end
      when "mother"
        last_name = params["mother_last_name"].soundex rescue nil
        first_name = params["mother_first_name"].soundex rescue nil
        results = Person.by_mother_last_name_and_first_name.key([last_name, first_name])
      when "father"
        last_name = params["father_last_name"].soundex rescue nil
        first_name = params["father_first_name"].soundex rescue nil
        results = Person.by_father_last_name_and_first_name.key([last_name, first_name])
      when "informant_name"
        last_name = params["informant_last_name"].soundex rescue nil
        first_name = params["informant_first_name"].soundex rescue nil
        results = Person.by_informant_last_name_and_first_name.key([last_name, first_name])
      when "informant_address"
        if params[:informant_country] != "Malawian"
          country_id = Nationality.by_name(params[:informant_country]).last.id rescue nil
          results = Person.by_home_country_id.key(country_id)
        else
          district_id = District.by_name.key(params[:informant_district]).last.id rescue nil
          ta_id = TraditionalAuthority.by_district_id_and_name.key([district_id, params[:informant_ta]]).last.id rescue nil
          village_id = Village.by_ta_id_and_name.key([ta_id, params[:informant_village]]).last.id rescue nil
          results = Person.by_informant_current_village_id.key(village_id)
        end
    end

    if has_role( "Add cause of death") && results.length > 0
      cause_available = ['cause_of_death1',     'cause_of_death2',
      'cause_of_death3',                        'cause_of_death4',
      'onset_death_interval1',            'onset_death_interval2',
      'onset_death_interval3',            'onset_death_interval4',
      'cause_of_death_conditions',              'manner_of_death',
      'other_manner_of_death',                 'death_by_accident',
      'other_death_by_accident', 'icd_10_code'].collect{|key| eval("results.last.#{key}")}.compact.length > 0 rescue false

      if cause_available
        redirect_to "/cause_of_death_preview?person_id=#{results.last.id}" and return
      else
        redirect_to "/cause_of_death?person_id=#{results.last.id}" and return
      end
    end

    @cases = []
    results.each do |person|
      @cases << {
          drn: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH REGISTRATION NUMBER"]).last.identifier rescue nil),
          den: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH ENTRY NUMBER"]).last.identifier rescue nil),
          first_name: person.first_name,
          middle_name:  person.middle_name,
          last_name:  person.last_name,
          dob:        person.birthdate.strftime("%d/%b/%Y"),
          gender:     person.gender,
          person_id:  person.id
      }
    end

    render :template => "case/default"
  end

  def cause_of_death_list

      diagnosis_list_csv = CSV.foreach("#{Rails.root}/app/assets/data/diagnoses_csv.csv", :headers => false)

      diagnosis_list = diagnosis_list_csv.collect{|row| row[1] unless row[1].blank?}

      diagnosis_list << ""

      render :text => diagnosis_list.sort
      
  end

  def cause_of_death
    @title = "Cause of death"
    @person = Person.find(params[:person_id])
  end

  def save_cause_of_death
    @person = Person.find(params[:person_id])
    i = 1
    while i < 4  do
       interval_unit = params["interval_unit#{i}"]

       case interval_unit
       when "Second(s)"
          params["onset_death_interval#{i}"] = params["onset_death_interval#{i}"]
       when "Minute(s)"
          params["onset_death_interval#{i}"] = params["onset_death_interval#{i}"].to_i * 60
       when "Hour(s)"
          params["onset_death_interval#{i}"] = params["onset_death_interval#{i}"].to_i * 60 * 60
       when "Day(s)"
          params["onset_death_interval#{i}"] = params["onset_death_interval#{i}"].to_i * 60 * 60 * 24
       when "Week(s)"  
          params["onset_death_interval#{i}"] = params["onset_death_interval#{i}"].to_i * 60 * 60 * 24 * 7 
       when "Month(s)"  
          params["onset_death_interval#{i}"] = params["onset_death_interval#{i}"].to_i * 60 * 60 * 24 * 30
       else  
       end
       i +=1
    end
    #tobe revised
    params[:cause_of_death_conditions] = params[:cause_of_death_conditions].join(",").to_s

    @person.keys.each do |k|
      if params.keys.include?(k)
        @person[k] = params[k]
      end
    end

    @person.save

    flash[:success] = "Record updated successfully"
    redirect_to "/search?person_id=#{params[:person_id]}"
  end

  def cause_of_death_preview
    @person = Person.find(params[:person_id])
    @person = sec_to_readable(@person)
  end
  
  def print_preview
    @section = "Print Preview"
    @targeturl = "/print" 
    @person = Person.find(params[:person_id])
    @available_printers = CONFIG["printer_name"].split(',')
    render :layout => "application"
  end
  
  def death_certificate_preview
   
    @person = Person.find(params[:id])

    @drn = PersonIdentifier.by_person_record_id_and_identifier_type.key([@person.id, "DEATH REGISTRATION NUMBER"]).last.identifier
    @den = PersonIdentifier.by_person_record_id_and_identifier_type.key([@person.id, "DEATH ENTRY NUMBER"]).last.identifier

    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png") rescue nil

    if @barcode.nil?
      process = Process.fork{`bin/generate_barcode #{@drn} #{@person.id} #{CONFIG['barcodes_path']}`}
      Process.detach(process)
    end

    sleep(0.5)

    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png")

    render :layout => false, :template => 'hq/death_certificate'

  end
  
  def death_certificate
    @person = Person.find(params[:id])
    @drn = PersonIdentifier.by_person_record_id_and_identifier_type.key([@person.id, "DEATH REGISTRATION NUMBER"]).last.identifier
    @den = PersonIdentifier.by_person_record_id_and_identifier_type.key([@person.id, "DEATH ENTRY NUMBER"]).last.identifier
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png") rescue nil
    
    if @barcode.nil?
      process = Process.fork{`bin/generate_barcode #{@drn} #{@person.id} #{CONFIG['barcodes_path']}`}
      Process.detach(process)
    end
    
    sleep(1)    
     
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png")
    
    if CONFIG['pre_printed_paper'] == true &&  GlobalProperty.find("paper_size").value == "A4"
       render :layout => false, :template => 'hq/death_certificate_print'
    elsif CONFIG['pre_printed_paper'] == true &&  GlobalProperty.find("paper_size").value == "A5"
       render :layout => false, :template => 'hq/death_certificate_print_a5'
    else
       render :layout => false
    end
    
  end
  
  def do_print_these
    
    selected = params[:selected].split("|")

    paper_size = GlobalProperty.find("paper_size").value rescue "A4"
    
    if paper_size == "A4"
       zoom = 0.83
    elsif paper_size == "A5"
       zoom = 0.6
    end
     
    selected.each do |key|

      person = Person.find(key.strip)

      next if person.blank?
      
      status = PersonRecordStatus.by_person_recent_status.key(person.id).last
      status.voided = true
      status.save

      PersonRecordStatus.create(:person_record_id => person.id, 
                                :district_code => status.district_code,
                          			:creator => @current_user.id, 
                                :status => "HQ CLOSED")
      
      id = person.id
      
      print_url = "wkhtmltopdf --zoom #{zoom} --page-size #{paper_size} --username #{CONFIG["print_user"]} --password #{CONFIG["print_password"]} #{CONFIG["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/death_certificate/#{id} #{CONFIG['certificates_path']}#{id}.pdf\n"    
      
      t4 = Thread.new {

        Kernel.system print_url

        sleep(4)

        Kernel.system "lp -d #{params[:printer_name]} #{CONFIG['certificates_path']}#{id}.pdf\n"

        sleep(5)
        
      }

      sleep(1)

    end
    
   redirect_to "/print" and return
  
  end
  
  def print_certificates
  
  end

  def districts

    if params[:place].present? && params[:place] == "Hospital/Institution"

      cities = ["Lilongwe City", "Blantyre City", "Zomba City", "Mzuzu City"]

      district = District.by_name.each

      render :text => district.collect { |w| "<li>#{w.name}" unless cities.include? w.name }.join("</li>")+"</li>"

    else
      district = District.by_name.each

      render :text => ([""] + district.collect { |w| w.name}).sort

    end
  end


  def by_reporting_month_and_district
    results = {
        "graph_data" => [],
        "graph_categories" => []
    }

    today = DateTime.now
     [(today - 11.months),  (today - 10.months), (today - 9.months), (today - 8.months),
        (today - 7.months), (today - 6.months), (today - 5.months), (today - 4.months),
        (today - 3.months), (today - 2.months), (today - 1.months), (today)] .each do |date|

        status = ["DC APPROVED", "HQ APPROVED","DC REAPPROVED", "HQ REAPPROVED", "HQ COMPLETE", "HQ INCOMPLETE", "HQ DUPLICATE",
                  "HQ POTENTIAL DUPLICATE", "HQ CLOSED", "HQ POTENTIAL INCOMPLETE",
                  "HQ DISPATCHED", "HQ PRINT", "HQ REPRINT", "HQ AMMEND", "DC AMMEND"].uniq
        month = date.strftime("%b`%y")
        count = 0.0
        status.each do |state|

            if params[:district].blank?
              start = state + "_" + date.beginning_of_month.strftime("%Y-%m-%d")
              endd = state + "_" + date.end_of_month.strftime("%Y-%m-%d")
              count = count + PersonRecordStatus.by_record_status_and_created_at.startkey(start).endkey(endd).each.count
            else
              district = params[:district].gsub("_", "-")
              code = District.by_name.key(district).last.id rescue ""
              start = code+"_"+state + "_" + date.beginning_of_month.strftime("%Y-%m-%d")
              endd = code+"_"+state + "_" + date.end_of_month.strftime("%Y-%m-%d")
              count = count + PersonRecordStatus.by_district_code_and_record_status_and_created_at.startkey(start).endkey(endd).each.count
            end
        end
        results['graph_categories'] << month
        results['graph_data'] << count
     end

    render :text => results.to_json
  end

  def by_record_status
    results = {}

    sent  = [
        ["dc_approved", ["DC APPROVED"]],
        ["hq_print", ["HQ PRINT"]],
        ["hq_reprint", ["HQ REPRINT"]],
        ["hq_duplicate", ["HQ POTENTIAL DUPLICATE", "HQ DUPLICATE", "HQ CONFIRMED DUPLICATE"]],
        ["hq_incomplete", ["HQ POTENTIAL INCOMPLETE", "HQ INCOMPLETE"]],
        ["hq_printed", ["HQ CLOSED"]],
        ["hq_dispatched", ["HQ DISPATCHED"]]
     ]

    sent.each do |id, states|
        if params[:district].blank?
          results[id] = PersonRecordStatus.by_status.keys(states).each.count
        else
          district = params[:district].gsub("_", "-")
          code = District.by_name.key(district).last.id rescue ""
          states = states.collect{|s| code+"_"+s}
          results[id] = PersonRecordStatus.by_district_code_and_status.keys(states).each.count
        end
    end

    render :text => results.to_json
  end

  def facilities

    district_param = params[:district] || '';

    if !district_param.blank?

      district = District.by_name.key(district_param.to_s).first

      facilities = HealthFacility.by_district_id.keys([district.id]).each
    else
      facilities = HealthFacility.by_name.each
    end

    list = []
    facilities.each do |f|
      if !params[:search_string].blank?
        list << f if f.name.match(/#{params[:search_string]}/i)
      else
        list << f
      end
    end

    render :text =>  ([""] + list.collect { |w| w.name}.uniq).sort
  end

  def nationalities
    nationalities = Nationality.all
    malawi = Nationality.by_nationality.key("Malawian").last
    list = []
    nationalities.each do |n|
      if !params[:search_string].blank?
        list << n if n.nationality.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    if "Malawian".match(/#{params[:search_string]}/i) || params[:search_string].blank?
      list = [malawi] + list
    end

    render :text =>  ([""] + list.collect { |w| w.nationality}.uniq)

  end

  def tas

    result = []

    if !params[:district].blank?

      district = District.by_name.key(params[:district].strip).first

      result = TraditionalAuthority.by_district_id.key(district.id)
    else

      result = TraditionalAuthority.by_district_id

    end

    list = []
    result.each do |r|
      if !params[:search_string].blank?
        list << r if r.name.match(/#{params[:search_string]}/i)
      else
        list << r
      end
    end

    render :text =>  ([""] + list.collect { |w| w.name}.uniq).sort
  end


  def villages

    result = []

    if !params[:district].blank? and !params[:ta].blank?

      district = District.by_name.key(params[:district].strip).first

      ta =TraditionalAuthority.by_district_id_and_name.key([district.id, params[:ta]]).first

      result = Village.by_ta_id.key(ta.id.strip)

    else
      result = Village.by_ta_id

    end

    list = []
    result.each do |r|
      if !params[:search_string].blank?
        list << r if r.name.match(/#{params[:search_string]}/i)
      else
        list << r
      end
    end

    render :text =>  ([""] + list.collect { |w| w.name}.uniq).sort

  end

  def signature
    @property = GlobalProperty.new
    @section = "Change Signature"
    @user = User.new
    @signatory =  GlobalProperty.find("signatory").value rescue nil
  end
  
  def paper_size
    @property = GlobalProperty.new
    @section = "Change Paper Size"
    @user = User.new
    @papersize =  GlobalProperty.find("paper_size").value rescue nil
  end
  
  def create_property
    papersize = params[:property][:paper_setting] rescue nil
    admin_password = params[:global_property][:admin_password] rescue nil
    signatory_password = params[:global_property][:signatory_password] rescue nil
    signatory_username =  params[:global_property][:value] rescue nil
    
    if papersize.present?
        @papersize =  GlobalProperty.find("paper_size") rescue nil
        if @papersize.blank?
          GlobalProperty.create(setting: "paper_size", value: params[:property][:paper_setting])
        else
          @papersize.update_attributes(value: params[:property][:paper_setting])
          flash[:notice] = "Changed paper size"
        end
    elsif admin_password.present? && signatory_password.present? && signatory_username.present?
         
        user = User.current_user
        
        if user.role.downcase == "system administrator" && user.password_matches?(admin_password)
       
          signatory = User.by_username.key(signatory_username).first rescue nil
          if signatory.present?
        
           if signatory.role.downcase == "certificate signatory" && signatory.password_matches?(signatory_password)
              @signatory =  GlobalProperty.find("signatory") rescue nil
              if @signatory.blank?
                GlobalProperty.create(setting: "signatory", value: signatory_username)
                flash[:notice] = "Assigned signatory"
              else
                @signatory.update_attributes(value: signatory_username)
                flash[:notice] = "Updated signatory"
              end

           else
           	flash[:error] = "Wrong signatory or wrong signatory password"
           end
          
          else
           flash[:error] = "Unauthorised user" 
          end
        else
          flash[:error] = "Unauthorised user"
        end
        
    end
    
    redirect_to "/" and return	
    
  end

  def manage_duplicates
    @person = Person.find(params[:person_id])
    @duplicates = search_similar_record(@person)
    @title = "Manage Duplicates"
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


  def get_comments
    @person = Person.find(params[:person_id])
    @comments = []

    Audit.by_record_id.key(@person.id).each do |audit|
      user = User.find(audit.user_id)
      user_name = (user.first_name + " " + user.last_name)
      ago = ""
      if (audit.created_at.to_date == Date.today)
        ago = "today"
      else
        ago = (Date.today - audit.created_at.to_date).to_i
        ago = ago.to_s + (ago.to_i == 1 ? " day ago" : " days ago")
      end
      @comments << {
          "created_at" => audit.created_at.to_time,
          'user' => user_name,
          'user_role' => user.role,
          'level' => audit.level,
          'comment' => audit.reason,
          'date_added' => ago
      }
      @comments = @comments.sort_by{|c| c['created_at']}
    end

    render :text => @comments.to_json
  end

  def ajax_save_comment
    @person = Person.find(params[:person_id])

    audit =  Audit.create(
      "reason" => params['comment'],
      "user_id" => @current_user.id,
      "record_id" => @person.id,
      "level" => "Person",
      "type" => (params["next_status"].gsub(/\-/, '') rescue nil),
      "site_id" => CONFIG['district_code']
    )

    user = User.find(audit.user_id)
    user_name = (user.first_name + " " + user.last_name)
    ago = ""
    if (audit.created_at.to_date == Date.today)
      ago = "today"
    else
      ago = (Date.today - audit.created_at.to_date).to_i
      ago = ago.to_s + (ago.to_i == 1 ? " day ago" : " days ago")
    end

    render :text => {
        "created_at" => audit.created_at.to_time,
        'user' => user_name,
        'user_role' => user.role,
        'level' => audit.level,
        'comment' => audit.reason,
        'date_added' => ago
    }.to_json
  end

  def tasks
=begin
  var tasks = [
    ['View','View open cases','/tasks'],
    ['Printed','View printed cases','/tasks'],
    ['Dispatched','View dispatched certificates','/tasks'],
    ['Conflict cases','View cases with queries','/tasks'],
    ['Rejected cases','View rejected cases','/tasks'],
    ['Re-printing','View cases approved for re-reprinting','/tasks'],
    ['Potential duplicates','Approve potential duplicates','/tasks']
];

=end

    @tasks = []

    if has_role("View a record")
      @tasks << ['Open cases','View open cases','/open_cases','manage-cases.png']
    end

    if has_role("View closed cases")
      @tasks << ['View closed cases','View closed cases','/closed_cases','lock.png']
    end

    if has_role("Manage incomplete records")
      @tasks << ['View incomplete cases','View incomplete cases','/incomplete_cases','']
    end

    if has_role("Manage incomplete records") 
      @tasks << ['Reject cases','Reject cases','/rejected_cases','']
    end

    if has_role("View closed cases")
      @tasks << ['Dispatched cases','View dispatched certificates','/dispatched','dispatch.png']
      @tasks << ['Conflict cases','View cases with queries','/conflict','conflict_case.png']
    end

    if has_role("Manage incomplete records") 
      @tasks << ['Re-approve cases','Re-approve cases','/re_approved_cases','']
      @tasks << ['Reject/Approve cases','Reject/Approve cases','/rejected_and_approved_cases','']
    end

    if has_role("View closed cases")
      @tasks << ['Closed case','View all closed cases','/dispatched','close-case.png']
      @tasks << ['Conflict cases','View cases with queries','/conflict','']
    end

    if has_role("Manage incomplete records")
      @tasks << ['Re-approved cases','View re-approved cases','/re_approved_cases','']
      @tasks << ['Rejected/Approved cases','View rejected and approved_cases','/rejected_and_approved_cases','']
    end

    if has_role("Reject a record")
      @tasks << ['Reject record','Reject record','/dm_reject','']
    end

    if has_role("Void outstanding records")
      @tasks << ['Void cases','Void cases','/void_cases','']
      @tasks << ['Voided cases','View void cases','/voided_cases','']
    end

    if has_role("View closed cases")
      @tasks << ['Approve for re-printing','Approve for re-printing','/approve_for_reprinting','']
      @tasks << ['Potential duplicates','View potential duplicates','/approve_potential_duplicates','']
    end

    if has_role("Make ammendments")
      @tasks << ['View requests','View requests','/view_requests','']
    end

    if has_role("Authorise printing")
      @tasks << ['Approve for printing','Approve for printing','/approve_for_printing','']
      @tasks << ['Print Certificates','Print Certificates','/print','']
      @tasks << ['Re-print certificates','Re-print certificates','/re_print','']
      @tasks << ['Dispatch print outs','View dispatched print outs','/dispatch_printouts','']
    end 

    if has_role("Authorise reprinting of a certificate")
      @tasks << ['Approve re-printing','Approve for re-printing','/approve_reprint','']
    end

    if has_role(("Assess certificate quality"))
      @tasks << ['Verify certificates','Verify certificates','/verify_certificates','']
    end



  end

  def sec_to_readable(person)
    (1..4).each do |i|
      secs = person["onset_death_interval#{i}"].to_i
      time_to_string = [[60, :second], [60, :minute], [24, :hour], [365, :day],[1000, :year]].map{ |count, name|
        if secs > 0
          secs, n = secs.divmod(count)
          if n > 0 
            if n == 1
              "#{n.to_i} #{name}"
            elsif n > 1
              "#{n.to_i} #{name}s"
            end
          end
        end
      }.compact.reverse.join(' ')
      person["onset_death_interval#{i}"] = time_to_string
    end
    return person
  end

end
