class ReportsController < ApplicationController
  def index
  	@tasks = []
  	if has_role( "Add cause of death")
  		@tasks << ['Cause of death','Reports on all cause of death ','/causes_of_death','']
	    @tasks << ['Maner of death','Reports on maner of deaths ','/manner_of_death','']
  	else
	    @tasks << ['Print Dispatch Note','Printing Dispatch note','','']
	    @tasks << ['Registered deaths','Reports on all records with DEN','','']
	    @tasks << ['Approved Records','Reports on records approved at HQ by DM ','','']
	    @tasks << ['Voided record report','All voided records with status where it was voided','','']
	    @tasks << ['Death reported','All records entered in the system','','']
	    @tasks << ['Amendments report','All records amended','','']
	    @tasks << ['Lost/Damaged','Reports on all lost/damaged records ','','']
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
end
