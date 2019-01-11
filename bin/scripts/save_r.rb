count = PersonRecordStatus.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	PersonRecordStatus.by__id.page(page).per(pagesize).each do |status|
		status.save
	end
end