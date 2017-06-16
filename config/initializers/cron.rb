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
if Rails.env == 'development'
    LoadMysql.perform_in(600)
else
    midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
    now = Time.now
    diff = (midnight  - now).to_i
  	LoadMysql.perform_in(diff)
end