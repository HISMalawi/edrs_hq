class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery	
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_user, :check_cron_jobs, :except => ['login', 'logout', 'death_certificate','dispatch_preview']
  
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
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
              place_of_death = person.place_of_death_village
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
              place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
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
      elsif person.place_of_death  && person.place_of_death =="Home"
          if person.place_of_death_village.present? && person.place_of_death_village.to_s.length > 0
            if person.place_of_death_village == "Other"
               place_of_death = person.other_place_of_death_village
            else
               place_of_death = person.place_of_death_village
            end
             
          end
          if person.place_of_death_ta.present? && person.place_of_death_ta.to_s.length > 0
            if person.place_of_death_ta == "Other"
                place_of_death = "#{place_of_death}, #{person.other_place_of_death_ta}"
            else
                place_of_death = "#{place_of_death}, #{person.place_of_death_ta}"
            end
              
          end
          if person.place_of_death_district.present? && person.place_of_death_district.to_s.length > 0
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
