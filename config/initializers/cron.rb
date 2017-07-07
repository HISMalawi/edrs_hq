if CONFIG['site_type'].to_s != "facility"
    if (defined? PersonIdentifier.can_assign_drn).nil?
       PersonIdentifier.can_assign_drn = true
    end
    AssignDrn.perform_in(3)
end

GenerateStats.perform_in(10)
if Rails.env == 'development'
    UpdateSyncStatus.perform_in(10)
else
  	UpdateSyncStatus.perform_in(1000)
end