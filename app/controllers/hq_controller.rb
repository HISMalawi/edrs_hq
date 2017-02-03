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

  def cause_of_death
    @title = "Cause of death"
    @person = Person.find(params[:person_id])
  end

  def save_cause_of_death
    @person = Person.find(params[:person_id])
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
      p = Process.fork{`bin/generate_barcode #{'123FRE'} #{@person.id} #{CONFIG['barcodes_path']}`}
      Process.detach(p)
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
      p = Process.fork{`bin/generate_barcode #{"123FRE"} #{@person.id} #{CONFIG['barcodes_path']}`}
      Process.detach(p)
    end
    
    sleep(1)    
     
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png")
    
    render :layout => false
    
  end
  
  def death_certificate_print
    @person = Person.find(params[:id])
    
    if CONFIG['pre_printed_paper'] == true
       render :layout => false, :template => 'hq/death_certificate_print'
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

      PersonRecordStatus.create(:person_record_id => person.id, :district_code => status.district_code,
        			:creator => @current_user.id, :status => "HQ CLOSED")
      
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


end
