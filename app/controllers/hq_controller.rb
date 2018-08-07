class HqController < ApplicationController
  def dashboard

    @icoFolder = nil

    @section = "Home"

    @targeturl = "/"

    @targettext = "Logout"

    @user = User.find_by_username(session[:current_user_id])

    @districts = {}
    District.all.each do |d| 
      next if d.name.blank?
      @districts[d.name.downcase.gsub(/\-|\_|\s+/, '_').strip] = d.id   unless d.name.include?("City")
    end
  end

  def dashbord_data

    data = RestClient.get("#{SETTINGS['app_jobs_url']}/application/get_stats")

    render :text => data
    
  end
  def search
    @title = "Search Death Records"
  end

  def quality_control
    @section = "Quality control"
    render :layout => "landing"
  end

  def quality_reopen
    render :layout => "touch"
  end

  def quality_check
      if params[:verdict] == "No"
          person = Person.by_npid.key(params[:certificate_barcode]).last
          PersonRecordStatus.change_status(person,"HQ RE PRINT",(params[:reason].present? ? params[:reason] : nil))
      end
      redirect_to "/hq/quality_reopen"
  end

  def do_search

    results = []
    @title = "Search Results"
    @statuses = []
    @districts = []
    District.all.each do |d| 
      next if d.name.blank?
      next if d.name.include?("City")
      @districts << d.name 
    end
    case params[:search_type]
      when "barcode"
          if ["Quality Supervisor"].include?(User.current_user.role)
              Person.by_npid.key(params[:barcode]).each do |person|
                results << person
              end
          else
              Barcode.by_barcode.key(params[:barcode]).each do |barcode|
              results << barcode.person
          end

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
      when "general_search"
        require 'simple_sql'
        map = {
                "details_of_deceased" => ['first_name', 'last_name', 'gender'],
                "home_address" => ['home_country', 'home_ta', 'home_village'],
                "mother" => ['mother_first_name', 'mother_last_name'],
                "father" => ['father_first_name', 'father_last_name'],
                "informant" => ['informant_first_name', 'informant_last_name'],
                "informant_address" => ['informant_current_district', 'informant_current_ta', 'informant_current_village'],
                "place_death" => ['place_of_death', 'place_of_death_district', 'place_of_death_ta', 'place_of_death_village', 'hospital_of_death', 'other_place_of_death']
              }

        results = SimpleSQL.query(map, params)
    end

    if (has_role( "Add cause of death") || has_role("Edit cause of death"))&& results.length > 0
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
    #raise results.inspect
    results.each do |person|
      @cases << {
          drn: (person.drn rescue nil),
          den: (person.den rescue nil),
          name: "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name}",
          gender:     person.gender,
          dob:        person.birthdate.strftime("%d/%b/%Y"),
          dod:        person.date_of_death.strftime("%d/%b/%Y"),
          place_of_death: place_of_death(person),
          person_id:  person.id
      }
    end

    render :template => "case/default"
  end

  def cause_of_death_list
      causes = []
      condition_a = Person.by_condition_a.keys
      condition_b = Person.by_condition_b.keys
      condition_c = Person.by_condition_c.keys
      condition_d = Person.by_condition_d.keys
      causes = condition_a + condition_b + condition_c + condition_d
      render :text => causes.uniq.sort
      
  end

  def cause_of_death
    @title = "Cause of death"
    @person = Person.find(params[:person_id])
  end

  def save_cause_of_death
    @person = Person.find(params[:person_id])
    


    i = 1
    while i <= 4  do
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
    params[:cause_of_death_conditions] = {}

    params[:other_significant_cause] = params[:other_significant_cause].delete_if { |key, value| value.to_s.strip == '' }
    params[:other_significant_cause].keys.each do |key|
      params[:cause_of_death_conditions][key] = {}
      params[:cause_of_death_conditions][key][:cause] = params[:other_significant_cause][key]
      params[:cause_of_death_conditions][key][:icd_code] = params[:other_significant_cause_icd_code][key]
    end
    params["coder"] = User.current_user.id
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
    flash[:success] = "Record updated successfully"
    redirect_to "/search?person_id=#{params[:person_id]}"
  end

  def nocause_available
    person = Person.find(params[:id])
    person.cause_of_death_available = "No"
    person.save
    redirect_to "/search"
  end


  def cause_of_death_preview
    @person = Person.find(params[:person_id])
    @person_icd_code = PersonICDCode.by_person_id.key(@person.id).first
    @person = to_readable(@person)
  end

  def generate_cases
    @section = "Generate Sample"
    @users = User.by_role.key("Coder").each
  end

  def generate_sample

    if params[:user] == "All"
        users = User.by_role.key("Coder").each
    else
        users = User.by__id.key(params[:user]).each
    end

    users.each do |user|

      sampling_frequency = SETTINGS['sampling_frequency']
  
      start_time = params[:start_date].to_date.beginning_of_day
      end_time = ((params[:end_date].to_date + 1.day).midnight - 1.second).to_time

      coders_records = Person.by_coder_and_coded_at.startkey([user.id, start_time]).endkey([user.id, end_time]).each.collect {|p| p.id}
      
      percent = ((SETTINGS['sample_percentage'].to_f/100) * coders_records.count).ceil

      puts percent
      
      sample = []

      for i in 0..(percent - 1)
        population = coders_records - sample
        id = sample_random(population)
        sample << id unless id.blank?
      end
      unless sample.blank?
        proficiency_sample = ProficiencySample.new
        proficiency_sample.coder_id = user.id
        proficiency_sample.sample = sample.sort
        proficiency_sample.start_time = start_time
        proficiency_sample.end_time = end_time
        proficiency_sample.date_sampled = Date.today
        proficiency_sample.save
      end

    end
    redirect_to "/sampled_cases"
  end

  def sample_random(population)
    random_number = rand(population.count - 1)
    random_id = population[random_number]
    return random_id
  end
  
  def print_preview
    @section = "Print Preview"
    @targeturl = "/print" 
    @person = Person.find(params[:person_id])
    @available_printers = SETTINGS["printer_name"].split(',')
    render :layout => "application"
  end
  
  def edit_icd_code
    person = Person.find(params[:id])

    person_code = PersonFinalICDCode.by_person_id.key(person.id).first

    if person_code.blank?
      person_code = PersonFinalICDCode.new
      person_code.person_id = person.id
    end

    person_code[params[:field]] = person[params[:field]]

    person_code.save

    person.update_attributes({"#{params[:field]}" => params[:code] })
    #person[params[:field]] = params[:code]

    #person.save
    render :text => "success"

    
  end

  def death_certificate_preview
   
    @person = Person.find(params[:id])


    @place_of_death = place_of_death(@person)

    @drn = @person.drn
    @den = @person.den

    @date_registered = @person.created_at
    PersonRecordStatus.by_person_record_id.key(@person.id).each.sort_by{|s| s.created_at}.each do |state|
      if state.status == "HQ ACTIVE"
          @date_registered = state.created_at
          break;
      end
    end
   
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png") rescue nil

    render :layout => false, :template => 'hq/death_certificate'

  end
  
  def death_certificate
    
    @person = Person.find(params[:id])
    @place_of_death = place_of_death(@person)
    @drn = @person.drn
    @den = @person.den
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png") rescue nil

    @date_registered = @person.created_at
    PersonRecordStatus.by_person_record_id.key(@person.id).each.sort_by{|s| s.created_at}.each do |state|
      if state.status == "HQ ACTIVE"
          @date_registered = state.created_at
          break;
      end
    end
    
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

      if !File.exist?("#{CONFIG['barcodes_path']}#{person.id}.png")
              create_barcode(person)
      end


      next if person.blank?
      PersonRecordStatus.change_status(person,"HQ PRINTED")
      id = person.id
      
      output_file = "#{CONFIG['certificates_path']}#{id}.pdf"

      input_url = "#{CONFIG["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/death_certificate/#{id}"

      #raise "wkhtmltopdf --zoom #{zoom} --page-size #{paper_size} #{input_url} #{output_file}"

      t4 = Thread.new {
        Kernel.system "wkhtmltopdf --zoom #{zoom} --page-size #{paper_size} #{input_url} #{output_file}"
        #PDFKit.new(input_url, :page_size => paper_size, :zoom => zoom).to_file(output_file)

        sleep(4)

        Kernel.system "lp -d #{params[:printer_name]} #{CONFIG['certificates_path']}#{id}.pdf\n"

        sleep(5)
        
      }

      sleep(1)
  
   end
    
   redirect_to "/print" and return
  
  end

  def sequencing
    
  end

  def do_dispatch_these


    write_file("#{Rails.root}/tmp/dispatch.txt", params[:ids].join(",").to_s)

    print_url ="/dispatch_preview"

    output_file = "#{CONFIG['dispatch_path']}Dispatched_#{Time.now.to_s.gsub(' ','_')}.pdf"

   

    input_url = "#{CONFIG["protocol"]}://#{request.env["SERVER_NAME"]}:#{request.env["SERVER_PORT"]}/dispatch_preview"

    t4 = Thread.new {
        Kernel.system "wkhtmltopdf  --orientation landscape --page-size A4 #{input_url} #{output_file}"
        #PDFKit.new(input_url, :page_size => 'A4',:orientation => 'Landscape').to_file(output_file)

        sleep(4)

        Kernel.system "lp -d #{params[:printer_name]} #{output_file}\n"

        sleep(5)
        
    }

    sleep(1)
    
    render :text =>"print"
  end

  def dispatch_preview

      @data = []
      @district = ""

      dispatch = "#{Rails.root}/tmp/dispatch.txt"

      dispatch_ids = File.open(dispatch) { |f| f.read }.to_s.split(",")
      dispatch_ids.each do |id|
        person = Person.find(id.gsub("\n",""))
        if @district.blank?
            @district = District.find(person.district_code).name
        end
        registered = PersonRecordStatus.by_person_record_id_and_status.key([person.id,"HQ ACTIVE"]).first
        if registered.present?
          date_registered = registered.created_at
        else
          date_registered = person.created_at
        end
        @data << {
            'name'                => "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name}".squish,
            'drn'                 => person.drn,
            'den'                 => person.den,
            'dob'                 => person.birthdate.to_date.strftime('%d/%b/%Y'),
            'dod'                 => person.date_of_death.to_date.strftime('%d/%b/%Y'),
            'sex'                 => person.gender,
            'place_of_death'      => place_of_death(person),
            'date_registered'     => (date_registered.to_date.strftime('%d/%b/%Y') rescue nil)
        }
        PersonRecordStatus.change_status(person,"HQ DISPATCHED")
      end

      render :layout => false
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

        status = ["HQ ACTIVE", "HQ APPROVED","DC REAPPROVED", "HQ REAPPROVED", "HQ COMPLETE", "HQ INCOMPLETE", "HQ DUPLICATE",
                  "HQ POTENTIAL DUPLICATE", "HQ PRINTED", "HQ POTENTIAL INCOMPLETE",
                  "HQ DISPATCHED", "HQ CAN PRINT", "HQ REPRINT", "HQ AMMEND", "DC AMMEND"].uniq
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
        ["dc_approved", ["HQ ACTIVE"]],
        ["hq_print", ["HQ CAN PRINT"]],
        ["hq_reprint", ["HQ REPRINT"]],
        ["hq_duplicate", ["HQ POTENTIAL DUPLICATE", "HQ DUPLICATE", "HQ CONFIRMED DUPLICATE"]],
        ["hq_incomplete", ["HQ POTENTIAL INCOMPLETE", "HQ INCOMPLETE"]],
        ["hq_printed", ["HQ PRINTED"]],
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

  def countries
    countries = Country.all
    malawi = Country.by_country.key("Malawi").last
    list = []
    countries.each do |n|
      if n.name =="Unknown"
        next if params[:special].blank?
      end
      if n.name =="Malawi"
        next unless params[:exclude].blank?
      end
      if !params[:search_string].blank?
        list << n if n.name.match(/#{params[:search_string]}/i)
      else
        list << n
      end
    end

    if ("Malawi".match(/#{params[:search_string]}/i) || params[:search_string].blank?) && params[:exclude] != "Malawi"
      list = [malawi] + list
    end

    countries = list.collect {|c| c.name}.sort

    if ("Malawi".match(/#{params[:search_string]}/i) || params[:search_string].blank?) && params[:exclude] != "Malawi"
      countries = [malawi.name] + countries
    end

    render :text => ([""] + countries.uniq)#.collect { |c| "<li>#{c}" }.join("</li>")+"</li>"

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

    PersonRecordStatus.by_person_record_id.key(params[:person_id]).each.sort_by {|k| k["created_at"]}.each do |status|
      user = User.find(status.creator)
      next if user.blank?
      next if status.comment.blank?
      user_name = (user.first_name + " " + user.last_name)
      ago = status.created_at.to_date.strftime("%d/%b/%Y")

      @comments << {
          "created_at" => status.created_at.to_time,
          'user' => user_name,
          'user_role' => user.role,
          'level' => nil,
          'comment' => status.comment,
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
      "audit_type" => (params["next_status"].gsub(/\-/, '') rescue nil),
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

    @tasks = []

    if has_role("View a record")
      @tasks << ['Active records','Active record from DC',"/open_cases?next_url=#{request.fullpath}",'manage-cases.png']
    end

    if has_role("Manage incomplete records")
      @tasks << ['Incomplete records from   DV','View incomplete cases',"/incomplete_cases?next_url=#{request.fullpath}",'']
      @tasks << ['Rejected Cases','View rejected cases',"/rejected_cases_tasks?next_url=#{request.fullpath}",'']
    end
    
    if has_role("Reject a record")
       @tasks << ['Conflict cases','View cases with queries',"/conflict?next_url=#{request.fullpath}",'conflict_case.png']
       @tasks << ['Rejected Cases','View rejected cases',"/rejected_cases_tasks?next_url=#{request.fullpath}",'']
    end

    if has_role("View closed cases")
      @tasks << ['View printed records','Print records',"/closed_cases?next_url=#{request.fullpath}",'lock.png']
      @tasks << ['Dispatched records','Dispatched records with an option of viewing a copy of printed certificate','/dispatched','dispatch.png']
    end

    if has_role("Void outstanding records")
      @tasks << ['Void cases','Void cases',"/void_cases?next_url=#{request.fullpath}",'']
      @tasks << ['Voided cases','View void cases',"/voided_cases?next_url=#{request.fullpath}",'']
    end

    if has_role(("Assess certificate quality"))
      @tasks << ['Verify certificates','Verify certificates',"/verify_certificates?next_url=#{request.fullpath}",'']
    end
     @section ="Manage Cases"

  end

  def rejected_cases_tasks
    @tasks = []
     if has_role("Manage incomplete records") 
      @tasks << ['Approved for printing','Approved records by DM for printing that were marked as incomplete by DS',"/approved_incomplete?next_url=#{request.fullpath}",'']
      @tasks << ['Rejected records','Incomplete records waiting to be sent to DC for editing',"/rejected_cases?next_url=#{request.fullpath}",'']
    end
    if has_role("Reject a record")
       @tasks << ['Approved for printing','Approved records by DM for printing that were marked as incomplete by DS',"/approved_incomplete?next_url=#{request.fullpath}",'']
      @tasks << ['Incomplete cases','Reject record',"/hq_incomplete?next_url=#{request.fullpath}",'']
    end
     @section ="Rejected Cases"
    render :template => "/hq/tasks"
  end

  def special_cases_tasks
    @tasks = []
    @tasks << ['Abnormal Deaths','Abnormal death records',"/special_cases?registration_type=Abnormal Deaths&next_url=#{request.fullpath}",'']
    @tasks << ['Dead on Arrival','Dead on Arrival',"/special_cases?registration_type=Dead on Arrival&next_url=#{request.fullpath}",'']
    @tasks << ['Unclaimed bodies','Unclaimed bodies record',"/special_cases?registration_type=Unclaimed bodies&next_url=#{request.fullpath}",'']
    @tasks << ['Missing persons','Missing persons record',"/special_cases?registration_type=Missing Person&next_url=#{request.fullpath}",'']
    @tasks << ['Death abroad','Death abroad record',"/special_cases?registration_type=Deaths Abroad&next_url=#{request.fullpath}",'']
    @tasks << ['Printed/Dispatched Certificates',"Printed/Dispatched Certificates","/printed_special_case?next_url=#{request.fullpath}",'']
    @tasks << ['Rejected special cases','Rejected special cases',"/rejected_special_case?next_url=#{request.fullpath}",'']
    @section ="Special Cases"
    render :template => "/hq/tasks"
  end

  def duplicate_cases_tasks
     @tasks = []
     if has_role("Manage incomplete records") 
      @tasks << ['Potential Duplicates','Records marked as potential duplicates',"/potential?next_url=#{request.fullpath}",'']
      @tasks << ['Can Confirm Duplicates','Can be sent to DC or Voided upon DM approval',"/can_confirm?next_url=#{request.fullpath}",'']
      @tasks << ['Confirmed Duplicates','Confirmed duplicates','','']
      @tasks << ['Approved for Printing','All potential duplicates that were approved and printed by DS, Option to view comments',"/approved_duplicate?next_url=#{request.fullpath}",'']
    end
    if has_role("Reject a record")
       @tasks << ['Resolve Duplicates','Records marked as potential duplicates',"/resolve_duplicates?next_url=#{request.fullpath}",'']
       @tasks << ['Approved for Printing','All potential duplicates that were approved and printed by DS, Option to view comments',"/approved_duplicate?next_url=#{request.fullpath}",'']
    end
    @section ="Duplicate Cases"
    render :template => "/hq/tasks"
  end

  def amendment_cases_tasks
    @tasks = []
    if has_role("Make ammendments") || has_role("Manage duplicates")
      @tasks << ['Lost/Damaged','All records that have been requested to be reprinted after first copy of the certificates was Lost/Damaged',"/reprint_requests?next_url=#{request.fullpath}",'']
      @tasks << ['Amendments','All records that has under gone changes after the certificate was printed',"/amendment_requests?next_url=#{request.fullpath}",'']
      if has_role("Make ammendments")
        @tasks << ['Rejected amended','All records that has under gone changes after the certificate was printed',"/rejected_requests?next_url=#{request.fullpath}",'']
      end
      @tasks << ['Printed/Dispatched Certificates','Printed/Dispatched Certificates',"/printed_amended_or_reprint?next_url=#{request.fullpath}",'']
    end
    @section ="Re-prints and amendments"
    render :template => "/hq/tasks"
  end

  def print_out_tasks
    @tasks = []
    if has_role("Authorise printing")
      @tasks << ['Approve for printing','Approve for printing',"/approve_for_printing?next_url=#{request.fullpath}",'']
      @tasks << ['Print Certificates','Print Certificates',"/print?next_url=#{request.fullpath}",'']
    end 
    if has_role("Authorise reprinting of a certificate")
      @tasks << ['Approve re-printing','Approve for re-printing',"/approve_reprint?next_url=#{request.fullpath}",'']
    end
     if has_role("Authorise printing")
      @tasks << ['Re-print certificates','Re-print certificates',"/re_print?next_url=#{request.fullpath}",'']
      @tasks << ['Dispatch print outs','View dispatched print outs',"/dispatch_printouts?next_url=#{request.fullpath}",'']
      @tasks << ['Closed Re-printed certificates','All reprinteed records, those didn’t pass QC, option to view comments',"/reprinted_certificates?next_url=#{request.fullpath}",'']
    end 
    @section ="Print out"
    render :template => "/hq/tasks"
  end

  def keep
    @tasks = []
    if has_role("Reject a record")
      @tasks << ['Reject record','Reject record','/dm_reject','']
    end
    if has_role("Manage incomplete records") 
      @tasks << ['Re-approve cases','Re-approve cases','/re_approved_cases','']
      @tasks << ['Reject/Approve cases','Reject/Approve cases','/rejected_and_approved_cases','']
      @tasks << ['Rejected cases','Rejected cases','/rejected_cases','']
    end
    if has_role("Make ammendments")
      @tasks << ['View requests','View requests','/view_requests','']
    end
     if has_role("View closed cases")
      @tasks << ['Conflict cases','View cases with queries','/conflict','conflict_case.png']
    end
    if has_role("View closed cases")
      @tasks << ['Closed case','View all closed cases','/dispatched','close-case.png']
      @tasks << ['Conflict cases','View cases with queries','/conflict','']
    end
    if has_role("View closed cases")
      @tasks << ['Approve for re-printing','Approve for re-printing','/approve_for_reprinting','']
      @tasks << ['Potential duplicates','View potential duplicates','/approve_potential_duplicates','']
    end
    return @tasks
  end

  def sampled_cases
    @sample_details = []
    sample = ProficiencySample.by_reviewed.key(false).each
    sample.each do |sp|
        user = User.find(sp.coder_id)
        @sample_details << {
                              name: "#{user.first_name} #{user.last_name}",
                              sample: sp.sample,
                              sample_id: sp.id,
                              date_sampled: sp.date_sampled
                            }
    end
    render :template => "hq/sampled_cases"
  end

  def review
    @sample = ProficiencySample.find(params[:id])
    @sample.results = {} if @sample.results.blank?
    @person = Person.find(@sample.sample.sort[params[:index].to_i])
    @person = to_readable(@person)
    @person_icd_code = PersonICDCode.by_person_id.key(@person.id).first  
    
  end

  def results
    sample = ProficiencySample.find(params[:id])
    count = 0
    sum = 0
    sample.sample.each do |sample|
        person_icd_code = PersonICDCode.by_person_id.key(sample).first 
        count = count + 1
        sum = sum + person_icd_code.review_results.to_f
    end

    render :text => (sum / count.to_f)
  end

  def finalizereview
    sample = ProficiencySample.find(params[:id])
    sample.update_attributes({reviewed: true})
    redirect_to "/sampled_cases"
  end

  def save_mark
    sample = ProficiencySample.find(params[:sample_id])
    case params[:decision]
    when "wrong"
      if sample.results.blank?
        results = {}
        results[params[:person_id]] = false
        sample.results = results
      else
        results = sample.results
        results[params[:person_id]] = false
        sample.results = nil
        sample.results = results
      end
      person = Person.find(params[:person_id])
      person.icd_10_code = params[:icd_10_code]
      person.save
      #sample.comment = params[:comment]
    when "correct"
      if sample.results.blank?
        results = {}
        results[params[:person_id]] = true
        sample.results = results
      else
        results = sample.results
        results[params[:person_id]] = true
        sample.results = nil
        sample.results = results
      end    
    end

    if params[:index].to_i == (sample.sample.count - 1)
        i = 0
        sample.sample.each do |id|
          if sample.results[id]
            i = i + 1
          end
        end

        sample.final_result = (i.to_f  / sample.sample.count) * 100
        sample.reviewed = true
        sample.supervisor = User.current_user.id
    end

    sample.save
    redirect_to "/review/#{params[:sample_id]}?index=#{(params[:index].to_i + 1) % sample.sample.count}"
  end

  def save_review
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

      j = 0
      while j < 10
        break if params["icd_10_#{j}i_reviewed"].blank?
        if params["icd_10_#{j}i_reviewed"]["result"].to_i == 1
            score = sore + 1
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

      render :text => "ok"
  end

  def save_proficiency_comment
      sample = ProficiencySample.find(params[:sample_id])
      sample.comment = params[:comment]
      if sample.save
          render :text => "ok"
      end
  end

  def to_readable(person)
    (1..4).each do |i|
      if person["cause_of_death#{i}"].blank?
        person["cause_of_death#{i}"] = (person["other_cause_of_death#{i}"] rescue "")
      end
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
  def find
    
  end

  private

end
