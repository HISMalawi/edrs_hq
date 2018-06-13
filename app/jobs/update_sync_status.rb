class UpdateSyncStatus
	include SuckerPunch::Job
  	workers 1
  	def perform
  		`bundle exec rake edrs:update_sync_status`
      update_sync_tracker = HQCronJobsTracker.first
      update_sync_tracker = HQCronJobsTracker.new if update_sync_tracker.blank?
      update_sync_tracker.time_last_updated_sync = Time.now
      update_sync_tracker.save
  		if Rails.env == "development"
          SuckerPunch.logger.info "Sync status update from DC Done"
      end
      
      if Rails.env == 'development'
        	UpdateSyncStatus.perform_in(10800)
      else
  			UpdateSyncStatus.perform_in(10800)
  		end
  	end
end