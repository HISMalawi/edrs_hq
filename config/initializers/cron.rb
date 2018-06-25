if HQCronJobsTracker.first.blank?
	HQCronJobsTracker.new.save
end
if CONFIG['site_type'].to_s != "facility"
    if (defined? PersonIdentifier.can_assign_drn).nil?
       PersonIdentifier.can_assign_drn = true
    end
   AssignDrn.perform_in(3)
end


=begin
	
GenerateStats.perform_in(60)

midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
now = Time.now
diff = (midnight  - now).to_i
GenerateSample.perform_in(diff)
if Rails.env == 'development'
    UpdateSyncStatus.perform_in(900)
else
  	UpdateSyncStatus.perform_in(diff)
end
CouchSQL.perform_in(600)
=end