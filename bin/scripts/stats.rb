require 'rails'
data_file = "dashboard.json"
newfile = File.open("#{Rails.root}/db/#{data_file}" , "w+")
newfile = File.new("#{Rails.root}/db/#{data_file}" , "w+") if newfile.blank?
beginning= Time.now.beginning_of_year
stats = {}
current_month_num = (Time.now).month.to_i
registered = []
approved = []
printed = []


(1..current_month_num).each do |i|
  			start_date = beginning
  			end_date = beginning.end_of_month

  			registered << Person.by_created_at.startkey(start_date.strftime("%Y-%m-%dT00:00:00:000Z")).endkey(end_date.strftime("%Y-%m-%dT23:59:59.999Z")).each.count

  			approved << PersonRecordStatus.by_status_and_created_at.startkey(["HQ ACTIVE",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey(["HQ ACTIVE",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
        
        printed << PersonRecordStatus.by_status_and_created_at.startkey(["HQ PRINTED",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey(["HQ PRINTED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count 
  			
        beginning = beginning + 1.months
  			
  			#puts "Iterator #{start_date} : #{end_date}"

end

stats[:year_registered] = registered
stats[:year_approved] = approved
stats[:year_printed] = printed

cummulatives = {}
cummulatives["Newly Received"] = PersonRecordStatus.by_record_status.key("HQ ACTIVE").each.count rescue 0
cummulatives["Verified by DV"] = PersonRecordStatus.by_record_status.key("HQ COMPLETE").each.count rescue 0
cummulatives["Marked incomplete by DV"] = PersonRecordStatus.by_record_status.key("HQ INCOMPLETE TBA").each.count rescue 0
cummulatives["Incomplete Records"]  = PersonRecordStatus.by_record_status.key("HQ INCOMPLETE").each.count rescue 0
cummulatives["Conflict cases"] = PersonRecordStatus.by_record_status.key("HQ CONFLICT").each.count rescue 0
cummulatives["Print Queue"] = PersonRecordStatus.by_record_status.key("HQ CAN PRINT").each.count rescue 0
cummulatives["Re pritnt- Queue"] = PersonRecordStatus.by_record_status.keys(["HQ REPRINT","HQ REPRINT REQUEST"]).each.count rescue 0
cummulatives["Suspected duplicates"] = PersonRecordStatus.by_record_status.keys(["HQ POTENTIAL DUPLICATE","HQ DUPLICATE"]).each.count rescue 0
cummulatives["Printed"] = PersonRecordStatus.by_record_status.key("HQ PRINTED").each.count rescue 0
cummulatives["Dispatched"] =  PersonRecordStatus.by_record_status.key("HQ DISPATCHED").each.count rescue 0
stats[:cummulative] = cummulatives;
      #puts "Stats generated :)::::::::::::::)::::::::::::::)::::::::::::::):::::::::::::)::::::::::::::::::::)"


stats["districts"] = {}

District.all.each do |district|
          next if district.name.include?("City")
          beginning= Time.now.beginning_of_year
          current_month_num = (Time.now).month.to_i
          stats["districts"][district.id] = {}
          district_registered = []
          district_approved = []
          district_printed = []

          (1..current_month_num).each do |i|
            start_date = beginning
            end_date = beginning.end_of_month
            district_registered << Person.by_district_code_and_created_at.startkey([district.id, start_date]).endkey([district.id, end_date]).each.count
            district_approved << PersonRecordStatus.by_district_code_and_status_and_created_at.startkey([district.id,"HQ ACTIVE",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey([district.id,"HQ ACTIVE",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
            
            district_closed  = PersonRecordStatus.by_district_code_and_status_and_created_at.startkey([district.id,"HQ PRINTED",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey([district.id,"HQ PRINTED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
            district_dispatched = PersonRecordStatus.by_district_code_and_status_and_created_at.startkey([district.id,"HQ DISPATCHED",start_date.strftime("%Y-%m-%dT00:00:00:000Z")]).endkey([district.id,"HQ DISPATCHED",end_date.strftime("%Y-%m-%dT23:59:59.999Z")]).each.count
            
            district_printed << district_closed.to_i + district_dispatched.to_i
            beginning = beginning + 1.months
            
            #puts "Iterator #{start_date} : #{end_date}"

          end

          stats["districts"][district.id][:year_registered] = district_registered
          stats["districts"][district.id][:year_approved] = district_approved
          stats["districts"][district.id][:year_printed] = district_printed
end
if newfile
  			 newfile.syswrite(stats.to_json)
else
  			puts "Unable to open file"	
end