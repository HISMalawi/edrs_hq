class ReportsController < ApplicationController
  def index
  	@tasks = []
  	if has_role( "Add cause of death") || has_role( "Edit cause of death")
      if has_role( "Edit cause of death")
          @tasks << ['Proficiency report','Reports on  the Proficiency of coders','/proficiency','']
      end
  		@tasks << ['Cause of death','Reports on all cause of death ','/causes_of_death','']
	    @tasks << ['Maner of death','Reports on maner of deaths ','/manner_of_death','']
  	else
	    @tasks << ['Registration district and Gender','Registration district and Gender','/reports/district_and_gender']
	    @tasks << ['User audit trail','Report for user audit trail','','']
      @tasks << ['By Place of Death','Place of Death','/reports/place_of_death','']
      @tasks << ['Cause of death','Reports on all cause of death ','/causes_of_death','']
	    @tasks << ['Maner of death','Reports on maner of deaths ','/manner_of_death','']
	  end
    @section ="Reports"
    render :template => "/hq/tasks"
  end
  def causes_of_death

  	@data = Report.causes_of_death(params[:district],params[:start_date],params[:end_date], params[:age_operator],params[:start_age],params[:end_age],params[:autopsy_requested])
  	@data_codes = @data.keys
  	@section ="Causes of death Reports"
  end
  def manner_of_death
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
    @districts = District.all.each
    @data = Report.general(params)
  end

  def district_and_gender
      @districts = District.all.each
  end

  def by_district_registered_and_gender

      @data = Report.district_registered_and_gender(params)
      render :text => @data.to_json
  end

  def cummulative
    
  end

  def place_of_death
      @districts = District.all.each

  end
  def by_place_of_death
      @data = Report.by_place_of_death(params)
      render :text => @data.to_json
  end

  def download_place_of_death
    districts = District.all.each
    file = "#{Rails.root}/tmp/PlaceOfDeath.csv"
    write_csv_header(file, ["District","Died and Registered in Pilot Facility","Died in Pilot Facility but registered at DR0","Non Pilot Health Facility","Home","Other", "Total"])
    districts.each do |district|
      next if district.name.include?("City")
      write_csv_content(file, [district.name,params["#{district.name}_input_died_and_registered_at_pilot"],params["#{district.name}_input_died_and_registered_at_pilot"],params["#{district.name}_input_non_pilot"],params["#{district.name}_input_home"],params["#{district.name}_input_other"],params["#{district.name}_input_Total"]])
    end
    send_file(file, :filename => "By Place of Death.csv", :disposition => 'inline', :type => "text/csv")
  end
end
