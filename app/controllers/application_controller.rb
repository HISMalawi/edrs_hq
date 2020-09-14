class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery	
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_user, :check_cron_jobs,:check_databases, :except => ['login', 'logout', 'death_certificate','dispatch_preview',
                                                                            "deaths","deaths_by_cause","covid_cases", "death_aggregates",
                                                                            "causes_aggregates","by_district_registered_and_gender",
                                                                            "manner_of_death" ,"age_disag_by_gender"]
  
  def has_role(role)
    current_user.activities_by_level("HQ").include?(role.strip)
  end

  def check_cron_jobs
    last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
    job_interval = SETTINGS['drn_assignment_interval']
    job_interval = 1.5 if job_interval.blank?
    job_interval = job_interval.to_f
    now = Time.now

    if (now - last_run_time).to_f > job_interval
        if SETTINGS['site_type'].to_s != "facility"
          if (defined? PersonIdentifier.can_assign_drn).nil?
            PersonIdentifier.can_assign_drn = true
          end
          if SuckerPunch::Queue.stats["AssignDrn"]["workers"]["idle"].to_i == 1
            AssignDrn.perform_in(15)
          end
        end
        
    end

    process = fork{
      Kernel.system "curl -s #{SETTINGS['app_jobs_url']}/application/start_generate_stats"
      Kernel.system "curl -s #{SETTINGS['app_jobs_url']}/application/start_couch_to_mysql"
      Kernel.system "curl -s #{SETTINGS['app_jobs_url']}/application/start_update_sync"
    }
    Process.detach(process)
  end

  def check_databases
    create_query = "CREATE TABLE IF NOT EXISTS potential_search (
                    id int(11) NOT NULL AUTO_INCREMENT,
                    person_id varchar(255) NOT NULL UNIQUE,
                    content TEXT,
                    created_at datetime NOT NULL,
                    updated_at datetime NOT NULL,
                    PRIMARY KEY (id),
                    FULLTEXT KEY content (content)
                  )ENGINE=InnoDB DEFAULT CHARSET=latin1;"
    SimpleSQL.query_exec(create_query); 

    create_audit_trail_table = "CREATE TABLE IF NOT EXISTS audit_trail(
                                  audit_record_id VARCHAR(255) NOT NULL,
                                  record_id VARCHAR(255) NOT NULL,
                                  audit_type VARCHAR(50) DEFAULT NULL,
                                  level VARCHAR(50) NOT NULL,
                                  model VARCHAR(50) DEFAULT NULL,
                                  field VARCHAR(50) DEFAULT NULL,
                                  previous_value VARCHAR(255) DEFAULT NULL,
                                  current_value VARCHAR(255) DEFAULT NULL,
                                  reason VARCHAR(255) DEFAULT NULL,
                                  user_id VARCHAR(255) DEFAULT NULL, 
                                  site_id VARCHAR(255) DEFAULT NULL,
                                  site_type VARCHAR(50) DEFAULT NULL,
                                  ip_address VARCHAR(64) DEFAULT NULL,
                                  mac_address VARCHAR(255) DEFAULT NULL,
                                  change_log VARCHAR(255) DEFAULT NULL,
                                  creator VARCHAR(255) DEFAULT NULL,
                                  voided INT(1) DEFAULT NULL,
                                  created_at DATETIME DEFAULT NULL,
                                  updated_at DATETIME DEFAULT NULL,
                                  PRIMARY KEY (audit_record_id)) ENGINE=InnoDB DEFAULT CHARSET=latin1;;"          
    SimpleSQL.query_exec(create_audit_trail_table);     
  end

  def place_details(person)

    places = {}

    places['home_country'] = Nationality.find(person.nationality_id).nationality rescue ""

    places['place_of_death_district'] = District.find(person.place_of_death_district_id).name rescue ""

    places['hospital_of_death'] = HealthFacility.find(person.hospital_of_death_id).name rescue ""

    places['place_of_death_ta'] = TraditionalAuthority.find(person.place_of_death_ta_id).name rescue ""

    places['place_of_death_village'] = Village.find(person.place_of_death_village_id).name rescue ""

    places['current_district'] = District.find(person.current_district_id).name rescue ""

    places['current_ta'] = TraditionalAuthority.find(person.current_ta_id).name rescue ""

    places['current_village'] = Village.find(person.current_village_id).name rescue ""

    places['home_district'] = District.find(person.home_district_id).name rescue ""

    places['home_ta'] = TraditionalAuthority.find(person.home_ta_id).name rescue ""

    places['home_village'] = Village.find(person.home_village_id).name rescue ""

    places['informant_current_district'] = District.find(person.informant_current_district_id).name rescue ""

    places['informant_current_ta'] = TraditionalAuthority.find(person.informant_current_ta_id).name rescue ""

    places['informant_current_village'] = Village.find(person.informant_current_village_id).name rescue ""

    return places

  end

  def mysql_connection
     YAML.load_file(File.join(Rails.root, "config", "database.yml"))[Rails.env]
  end

  def potential_duplicate_full_text?(person)
      if person.middle_name.blank?
        score = (CONFIG['duplicate_score'].to_i - 1)
      else
        score = CONFIG['duplicate_score'].to_i
      end
      searchables = "#{person.first_name} #{person.last_name} #{ format_content(person)}"
      sql_query = "SELECT couchdb_id,title,content,MATCH (title,content) AGAINST ('#{searchables}' IN BOOLEAN MODE) AS score 
                  FROM documents WHERE MATCH(title,content) AGAINST ('#{searchables}' IN BOOLEAN MODE) ORDER BY score DESC LIMIT 5"
      results = SimpleSQL.query_exec(sql_query).split(/\n/)
      results = results.drop(1)

      potential_duplicates = []

      results.each do |result|
          data = result.split("\t");
          next if person.id.present? && person.id == data[0]
          potential_duplicates << data if data[3].to_i >= score
      end
      return potential_duplicates
   end
   #Format content
   def format_content(person)
     
     search_content = ""
      if person.middle_name.present?
         search_content = person.middle_name + ", "
      end 

      birthdate_formatted = person.birthdate.to_date.strftime("%Y-%m-%d")
      search_content = search_content + birthdate_formatted + " "
      death_date_formatted = person.date_of_death.to_date.strftime("%Y-%m-%d")
      search_content = search_content + death_date_formatted + " "
      search_content = search_content + person.gender.upcase + " "

      if person.place_of_death_district.present?
        search_content = search_content + person.place_of_death_district + " " 
      else
        registration_district = District.find(person.district_code).name
        search_content = search_content + registration_district + " " 
      end    

      if person.mother_first_name.present?
        search_content = search_content + person.mother_first_name + " " 
      end

      if person.mother_middle_name.present?
         search_content = search_content + person.mother_middle_name + " "
      end   

      if person.mother_last_name.present?
        search_content = search_content + person.mother_last_name + " "
      end

      if person.father_first_name.present?
         search_content = search_content + person.father_first_name + " "
      end 

      if person.father_middle_name.present?
         search_content = search_content + person.father_middle_name + " "
      end 

      if person.father_last_name.present?
         search_content = search_content + person.father_last_name
      end 

      return search_content.squish

  end

  def readable_format(result)
      person = Person.find(result[0])
      return [person.id, "#{person.first_name} #{person.middle_name rescue ''} #{person.last_name} #{person.gender}"+
                    " Born on #{DateTime.parse(person.birthdate.to_s).strftime('%d/%B/%Y')} "+
                    " died on #{DateTime.parse(person.date_of_death.to_s).strftime('%d/%B/%Y')} " +
                    " at #{person.place_of_death_district}"]
  end

  def place_of_death(person)
    place_of_death = ""
    case person.place_of_death
      when "Home"
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0 && person.place_of_death_village != "Other"
              place_of_death = person.place_of_death_village
          elsif person.other_place_of_death_village.present?
              place_of_death = person.other_place_of_death_village
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0 && person.place_of_death_ta != "Other"
              place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
          elsif person.other_place_of_death_ta.present?
              place_of_death = "#{place_of_death}, #{person.other_place_of_death_ta}"
          end
          if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
              place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
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
                  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
                end
                 
             end
      elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Home"

              if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
                 place_of_death = person.place_of_death_foreign_village
              end

              if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_district}"
              end

              if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_state}"
              end

              if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
                end
                 
              end
        elsif person.place_of_death_foreign && person.place_of_death_foreign.strip =="Other"
               if person.other_place_of_death.present? && person.other_place_of_death.to_s.length > 0
                 place_of_death = person.other_place_of_death
              end

              if person.place_of_death_foreign_village.present? && person.place_of_death_foreign_village.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_village}"
              end

              if person.place_of_death_foreign_district.present? && person.place_of_death_foreign_district.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_district}"
              end

              if person.place_of_death_foreign_state.present? && person.place_of_death_foreign_state.to_s.length > 0
                 place_of_death = "#{place_of_death}, #{person.place_of_death_foreign_state}"
              end

              if person.place_of_death_country.present? && person.place_of_death_country.to_s.length > 0
                if person.place_of_death_country == "Other"
                  place_of_death = "#{place_of_death}, #{person.other_place_of_death_country}"
                else
                  place_of_death = "#{place_of_death}, #{person.place_of_death_country}"
                end
                 
              end

      elsif person.place_of_death  && person.place_of_death =="Other"
                if person.other_place_of_death.present?
                    place_of_death  = person.other_place_of_death;
                end
                if person.place_of_death_district.present?
                    place_of_death = "#{place_of_death}, #{person.place_of_death_district}"
                end

    end
    return place_of_death 
  end

  def write_file(file, content)
    if !File.exists?(file)
        File.new(file, 'w')
        File.open(file, 'w') do |f|
            f.puts "#{content}"
        end
    else
         File.open(file, 'w') do |f|
            f.puts "#{content}"
        end
    end
  end

  def districts
    @district = District.all.each
  end
  def create_barcode(person)
    if person.npid.blank?
       npid = Npid.by_assigned.keys([false]).first
       person.npid = npid.national_id
       person.save
    end
    `bundle exec rails r bin/generate_barcode #{person.npid.present?? person.npid : '123456'} #{person.id} #{SETTINGS['barcodes_path']}`
  end

  def create_qr_barcode(person)
    if person.npid.blank?
       npid = Npid.by_assigned.keys([false]).first
       person.npid = npid.national_id
       person.save
    end
    `bundle exec rails r bin/generate_qr_code #{person.id} #{SETTINGS['qrcodes_path']}`    
  end
  def write_csv_header(file, header)
    CSV.open(file, 'w' ) do |exporter|
        exporter << header
    end
  end

  def write_csv_content(file, content)
    CSV.open(file, 'a+' ) do |exporter|
        exporter << content
    end
  end

  def calculate_age_to_death(birthdate, date_of_death=Time.now)
    birthdate = birthdate.to_time
    date_of_death = date_of_death.to_time
    different = date_of_death - birthdate
    if (different / 1.year).round(1).to_i >= 1
        return "#{(different / 1.year).round(1).to_i} years(s)" 
    elsif (different / 1.month).round(1) >= 1
        return "#{(different / 1.month).round(1).to_i} month(s)"
    elsif (different / 1.week).round(1) >= 1
        return "#{(different / 1.week).round(1).to_s} week(s)"
    elsif (different / 1.day).round(1) >= 1
        return "#{(different / 1.day).round(1).to_i} day(s)"
    else
        return "0 day"
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

  def time_to_divmod(seconds)
      t = seconds.to_i
      ss = t.divmod(60)[1]           
      mm = t.divmod(60)[0].divmod(60)[1]          
      hh = t.divmod(60)[0].divmod(60)[0].divmod(24)[1]
      dd = t.divmod(60)[0].divmod(60)[0].divmod(24)[0].divmod(7)[1]
      ww = t.divmod(60)[0].divmod(60)[0].divmod(24)[0].divmod(7)[0].divmod(4)[1]
      mm = t.divmod(60)[0].divmod(60)[0].divmod(24)[0].divmod(7)[0].divmod(4)[0].divmod(12)[1]
      yy = t.divmod(60)[0].divmod(60)[0].divmod(24)[0].divmod(7)[0].divmod(4)[0].divmod(12)[0]
      return [yy,mm,ww,dd, hh, mm, ss]
  end

  def read_onset_death_interval(person)
      i = 1
      while i < 5
         interval = time_to_divmod(person["onset_death_interval#{i}"])
         if interval[0] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[0]
            person["interval_unit#{i}"] = "Second(s)"
         end 
         if interval[1] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[1]
            person["interval_unit#{i}"] = "Minute(s)(s)"
         end 
         if interval[2] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[2]
            person["interval_unit#{i}"] = "Hour(s)"
         end
         if interval[3] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[3]
            person["interval_unit#{i}"] = "Day(s)"
         end 
         if interval[4] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[4]
            person["interval_unit#{i}"] = "Week(s)"
         end
         if interval[5] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[5]
            person["interval_unit#{i}"] = "Month(s)"
         end
         if interval[6] > 0 && person["onset_death_interval#{i}"].present?
            person["onset_death_interval#{i}"] = interval[6]
            person["interval_unit#{i}"] = "Year(s)"
         end          
        i = i + 1
      end
      return person
  end

  protected
  def check_user

    if !session[:user_id].blank?
      @current_user = current_user
      User.current_user = @current_user
      if @current_user.blank?
        reset_session
        redirect_to "/login"
      end
    else
      reset_session
      redirect_to "/login"
    end
  end

  def current_user
    User.find(session[:user_id])
  end
end
