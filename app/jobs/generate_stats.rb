class GenerateStats
	include SuckerPunch::Job
  	workers 1
  
  	def perform()
  		data_file = "dashboard.json"
      newfile = File.open("#{Rails.root}/app/assets/data/#{data_file}" , "w+")
  		newfile = File.new("#{Rails.root}/app/assets/data/#{data_file}" , "w+") if newfile.blank?
  		beginning= Time.now.beginning_of_year
  		stats = {}
  		current_month_num = (Time.now).month.to_i
  		registered = []
  		approved = []
  		printed = []
  		(1..current_month_num).each do |i|
  			start_date = beginning
  			end_date = beginning.end_of_month
  			registered << Person.by_created_at.startkey(start_date).endkey(end_date).each.count
  			approved << PersonRecordStatus.by_status_and_created_at.startkey(["DC APPROVED",start_date.strftime("%Y-%m-%dT00:00:000Z")]).endkey(["DC APPROVED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
        
        closed  = PersonRecordStatus.by_status_and_created_at.startkey(["HQ CLOSED",start_date.strftime("%Y-%m-%dT00:00:000Z")]).endkey(["HQ CLOSED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
  			dispatched = PersonRecordStatus.by_status_and_created_at.startkey(["HQ DISPATCHED",start_date.strftime("%Y-%m-%dT00:00:000Z")]).endkey(["HQ DISPATCHED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
        
        printed << closed.to_i + dispatched.to_i
  			beginning = beginning + 1.months
  			
  			#puts "Iterator #{start_date} : #{end_date}"

  		end
  		stats[:year_registered] = registered
  		stats[:year_approved] = approved
      stats[:year_printed] = printed
      cummulatives = {}
      cummulatives["Newly Registered"] = PersonRecordStatus.by_record_status.key("NEW").each.count rescue 0
      cummulatives["Print Queue"] = PersonRecordStatus.by_record_status.key("HQ PRINT").each.count rescue 0
      cummulatives["Re pritnt- Queue"] = PersonRecordStatus.by_record_status.keys(["HQ REPRINT","HQ REPRINT REQUEST"]).each.count rescue 0
      cummulatives["Suspected duplicates"] = PersonRecordStatus.by_record_status.keys(["HQ POTENTIAL DUPLICATE","HQ DUPLICATE"]).each.count rescue 0
      cummulatives["Incomplete Records"]  = PersonRecordStatus.by_record_status.key("HQ INCOMPLETE").each.count rescue 0
      cummulatives["Printed"] = PersonRecordStatus.by_record_status.key("HQ CLOSED").each.count rescue 0
      cummulatives["Printed and dispatched"] =  PersonRecordStatus.by_record_status.keys(["HQ CLOSED","HQ DISPATCHED"]).each.count rescue 0
      stats[:cummulative] = cummulatives;
      puts "Stats generated :)::::::::::::::)::::::::::::::)::::::::::::::):::::::::::::)::::::::::::::::::::)"
  		if newfile
  			 newfile.syswrite(stats.to_json)
  		else
  			puts "Unable to open file"	
  		end

  		GenerateStats.perform_in(600)
  	end
end