count = Barcode.count
pagesize = 200
pages = (count / pagesize) + 1

page = 1

id = []

while page <= pages
	Barcode.all.page(page).per(pagesize).each do |b|
		b.insert_update_into_mysql
	end
	page =  page + 1
end