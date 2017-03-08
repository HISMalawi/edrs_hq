class ReportsController < ApplicationController
  def index
  	@tasks = []
  	if has_role( "Add cause of death")
  		@tasks << ['Cause of death report','Cause of death report','','']
  	else
	    @tasks << ['Print Dispatch Note','Printing Dispatch note','','']
	    @tasks << ['Registered deaths','Reports on all records with DEN','','']
	    @tasks << ['Approved Records','Reports on records approved at HQ by DM ','','']
	    @tasks << ['Voided record report','All voided records with status where it was voided','','']
	    @tasks << ['Death reported','All records entered in the system','','']
	    @tasks << ['Amendments report','All records amended','','']
	    @tasks << ['Lost/Damaged','Reports on all lost/damaged records ','','']
	end
    @section ="Reports"
    render :template => "/hq/tasks"
  end
end
