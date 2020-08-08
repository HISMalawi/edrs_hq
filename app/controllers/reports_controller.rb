class ReportsController < ApplicationController
  def index
  	@tasks = []
  	if has_role( "Add cause of death") || has_role( "Edit cause of death")
      if has_role( "Edit cause of death")
          @tasks << ['Proficiency report','Reports on  the Proficiency of coders','/proficiency','']
      end
  		@tasks << ['Cause of death','Reports on all cause of death ','/causes_of_death','']
      @tasks << ['Maner of death','Reports on maner of deaths ','/manner_of_death','']
      @tasks << ['COVID-19 Cases','COVID-19 Case','/reports/covid','']
  	else
	    @tasks << ['Registration district and Gender','Registration district and Gender','/reports/district_and_gender']
	    @tasks << ['User audit trail','Report for user audit trail','/reports/user_audits?timeline=Today&next_url=/reports?next_url=/','']
      @tasks << ['By Place of Death','Place of Death','/reports/place_of_death','']
      @tasks << ['Cause of death','Reports on all cause of death ','/causes_of_death','']
      @tasks << ['Maner of death','Reports on maner of deaths ','/manner_of_death','']
      @tasks << ['COVID-19 Cases','COVID-19 Case','/reports/covid','']
	  end
    @section ="Reports"
    render :template => "/hq/tasks"
  end
  def causes_of_death
    @districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)
    @data = Report.causes_of_death(params)
  	#@data = Report.causes_of_death(params[:district],params[:start_date],params[:end_date], params[:age_operator],params[:start_age],params[:end_age],params[:autopsy_requested])
  	@data_codes = @data.keys
  	@section ="Causes of death Reports"
  end
  def manner_of_death
    @districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)
  	@data = Report.manner_of_death(params[:district],params[:start_date],params[:end_date], params[:age_operator],params[:start_age],params[:end_age],params[:autopsy_requested])
  	
  	@data_manners = @data.keys
  	@section ="Manner of death Reports"
  end
  def proficiency
      if params[:start_date].blank?
          start_date = Time.now.beginning_of_month
      else
          start_date = params[:start_date].to_time 
      end
      if params[:end_date].blank?
          end_date = Time.now
      else
          end_date = params[:end_date].to_time 
      end
      @sample_details = Report.proficiency(start_date,end_date)
      @section ="Proficiency report"
  end

  def death_reports
    @section = "Death report"
    @districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)
    @data = Report.general(params)
  end

  def district_and_gender
      @districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)
  end

  def by_district_registered_and_gender

      @data = Report.district_registered_and_gender(params)
      render :text => @data.to_json
  end

  def cummulative
    
  end

  def place_of_death
      @districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)

  end
  def by_place_of_death
      @data = Report.by_place_of_death(params)
      render :text => @data.to_json
  end

  def download_place_of_death
    districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)
    file = "#{Rails.root}/tmp/PlaceOfDeath.csv"
    write_csv_header(file, ["District","Died and Registered in Pilot Facility","Died in Pilot Facility but registered at DR0","Non Pilot Health Facility","Home","Other", "Total"])
    districts.each do |district|
      next if district.name.include?("City")
      write_csv_content(file, [district.name,params["#{district.name}_input_died_and_registered_at_pilot"],params["#{district.name}_input_died_and_registered_at_pilot"],params["#{district.name}_input_non_pilot"],params["#{district.name}_input_home"],params["#{district.name}_input_other"],params["#{district.name}_input_Total"]])
    end
    send_file(file, :filename => "By Place of Death #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}.csv", :disposition => 'inline', :type => "text/csv")
  end

  def download_cause_of_death

    file = "#{Rails.root}/tmp/CauseOfDeath.csv"
    write_csv_header(file, ["Code","Male","Female", "Total"])

    params.keys.each do |code|
      next if params[code]["TOTAL"].to_i == 0
      write_csv_content(file, [code,params[code]["MALE"],params[code]["FEMALE"],params[code]["TOTAL"]])
    end
    send_file(file, :filename => "Cause of Death #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}.csv", :disposition => 'inline', :type => "text/csv")
  end

  def user_audits
    @section ="User Audit"
    case params[:timeline]
    when "Today"
        @start_date = Time.now.strftime("%Y-%m-%d")
        @end_date = Date.today.to_time.strftime("%Y-%m-%d")
        @period = "Today (#{@start_date})"
    when "Current week"
        @start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d")
        @end_date = Date.today.strftime("%Y-%m-%d")
        @period = "Current week (From #{@start_date} to #{@end_date})"
    when "Current month"
        @start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d")
        @end_date = Date.today.to_time.strftime("%Y-%m-%d")
        @period = "Current month (From #{@start_date} to #{@end_date})"
    when "Current year"
        @start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d")
        @end_date = Date.today.to_time.strftime("%Y-%m-%d")
        @period = "Current year (From #{@start_date} to #{@end_date})"
    else
        @start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d")
        @end_date = DateTime.parse(params[:end_date]).to_time.strftime("%Y-%m-%d")
        @period = "From #{@start_date} to #{@end_date}"
    end
   
    
  end

  def get_audits
    data = Report.audits(params)
    render :text => data.to_json
  end

  def covid
    @districts = DistrictRecord.where("name NOT LIKE '%City'").order(:name)
    @start_date = "2019-12-01"
    @end_date = Time.now.strftime("%Y-%m-%d")
    @section ="COVID-19 Cases"
  end
  def covid_count
    render :text => Report.covid(params).to_json
  end

  #Dashboard
  def registration
      data = {}
      status_query = "status = 'DC ACTIVE'"
      case params[:status]
      when "reported"
        status_query = "status = 'DC ACTIVE'"
      when "registered"
        status_query = "status = 'HQ ACTIVE'"
      when "printed"
        status_query = "status IN ('DC PRINTED','HQ PRINTED')"
      when  "dispatched"
        status_query = "status IN ('DC DISPATCHED','HQ DISPATCHED')"
      end
      if params[:start_date].present?
          start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
      else
          start_age =Date.today.beginning_of_month.strftime("%Y-%m-%d")
      end

      if params[:end_date].present?
          end_date = params[:end_date].to_time.strftime("%Y-%m-%d")
      else
          end_date =Date.today.strftime("%Y-%m-%d")
      end
      data = {}
      gender = ["Male", "Female"]
      gender.each do |g|
        query = "SELECT t.name as District,count(*) as Total  FROM  
                  (SELECT DISTINCT person_record_id, a.district_code, d.name  
                    FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
                    inner join district d on p.district_code = d.district_id  
                    WHERE #{status_query} AND gender='#{g}'
                    AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >= '#{start_age}' 
                    AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <= '#{end_date}')
                t GROUP BY t.name"
          
          ActiveRecord::Base.connection.select_all(query).as_json.each do |row|
            data[row['District']] = {} if data[row['District']].blank?
            data[row['District']][g] = row['Total']
          end
      end
      render :text => data.to_json
  end

  def deaths
    data = {}
    category_query = ""
    ebrs_facilities = ['Kamuzu Central Hospital','Queen Elizabeth Central Hospital','Ntcheu District Hospital', 'Chitipa District Hospital']
    case params[:report]
    when "died_and_registered_at_edrs_facility"
        category_query = "AND a.hospital_of_death IN ('#{ebrs_facilities.join("','")}') 
                          AND a.hospital_of_death = a.place_of_registration "
    when "died_in_edrs_facility_and_registered_at_dro"
        category_query = "AND a.hospital_of_death IN ('#{ebrs_facilities.join("','")}') 
                        AND a.hospital_of_death != a.place_of_registration "
    when "non_edrs_facility"
        category_query = "AND a.hospital_of_death NOT IN ('#{ebrs_facilities.join("','")}') 
                        AND  a.place_of_death='Health Facility' "      
    when "home"
        category_query = " AND a.place_of_death = 'Home' "
    when "other"
        category_query = " AND a.place_of_death = 'Other' "
    when "coded_and_entered_in_edrs"
        category_query = " AND cause_of_death1 IS NOT NULL AND icd_10_code IS NOT NULL"
    end

    #status
    status_query = "status = 'DC ACTIVE'"
    case params[:status]
    when "reported"
      status_query = "status = 'DC ACTIVE'"
    when "registered"
      status_query = "status = 'HQ ACTIVE'"
    when "printed"
      status_query = "status IN ('DC PRINTED','HQ PRINTED')"
    when  "dispatched"
      status_query = "status IN ('DC DISPATCHED','HQ DISPATCHED')"
    end

    if params[:start_date].present?
        start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
    else
        start_age =Date.today.beginning_of_month.strftime("%Y-%m-%d")
    end

    if params[:end_date].present?
        end_date = params[:end_date].to_time.strftime("%Y-%m-%d")
    else
        end_date =Date.today.strftime("%Y-%m-%d")
    end

    data = {}
    ["Male","Female"].each do |g|
        query = "SELECT t.name as District, count(*) as Total  FROM  (SELECT DISTINCT person_record_id, a.district_code, d.name  
                    FROM people a inner join person_record_status p on a.person_id = p.person_record_id 
                    inner join district d on p.district_code = d.district_id  
                    WHERE #{status_query} AND gender='#{g}'
                    #{category_query}
                AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >='#{start_date}' 
                AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <='#{end_date}'
                ORDER BY d.name) t  GROUP BY  name;"
        ActiveRecord::Base.connection.select_all(query).as_json.each do |row|
                  data[row['District']] = {} if data[row['District']].blank?
                  data[row['District']][g] = row['Total']
        end 
    end
    
    render :text => data.to_json
  end

  def deaths_by_cause
      district_query = ''
      if params[:district].present?
        district_query = " AND district_code = '#{District.by_name.key(params[:district]).first.id}'" 
      end

      date_query = ''
      if params[:start_date].present?
          date_query = " AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >= '#{params[:start_date].to_time.strftime("%Y-%m-%d")}'"
      else
        date_query = " AND DATE_FORMAT(p.created_at,'%Y-%m-%d') >= '#{Date.today.beginning_of_month.strftime("%Y-%m-%d")}'"
      end
      if params[:end_date].present?
          date_query = "#{date_query} AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <= '#{params[:end_date].to_time.strftime("%Y-%m-%d")}'"
      else
        date_query = "#{date_query} AND DATE_FORMAT(p.created_at,'%Y-%m-%d') <= '#{Date.today.strftime("%Y-%m-%d")}'"
      end
      data = {}
      ['Male','Female'].each do |g|
        query = "SELECT c.final_code as FinalCode, count(*) as Total FROM people p INNER JOIN person_icd_codes c ON p.person_id = c.person_id
                WHERE  gender='#{g}' #{district_query} #{date_query} GROUP BY c.final_code"
        ActiveRecord::Base.connection.select_all(query).as_json.each do |row|
          data[row['FinalCode']] = {} if data[row['FinalCode']].blank?
          data[row['FinalCode']][g] = row['Total']
        end
      end
      render :text => data.to_json
    end

    def covid_cases
      if params[:start_date].present?
          start_date = params[:start_date].to_time.strftime("%Y-%m-%d")
      else
          start_age =Date.today.beginning_of_month.strftime("%Y-%m-%d")
      end

      if params[:end_date].present?
          end_date = params[:end_date].to_time.strftime("%Y-%m-%d")
      else
          end_date =Date.today.strftime("%Y-%m-%d")
      end
      data = {}
      ['Male','Female'].each do |g|
          query = "SELECT d.name as District, COUNT(*) as Total FROM  people p INNER JOIN covid_record c ON p.person_id = c.person_record_id
                    INNER JOIN district d on p.district_code = d.district_id 
                    WHERE
                    gender ='#{g}' AND
                    DATE_FORMAT(c.created_at,'%Y-%m-%d') >='#{start_date}' 
                    AND DATE_FORMAT(c.created_at,'%Y-%m-%d') <='#{end_date}' GROUP BY d.name;"
          ActiveRecord::Base.connection.select_all(query).as_json.each do |row|
                      data[row['District']] = {} if data[row['District']].blank?
                      data[row['District']][g] = row['Total']
            end 
      end

      render :text => data.to_json
    end
end
