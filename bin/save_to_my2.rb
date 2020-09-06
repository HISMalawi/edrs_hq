total_record = Person.count

page_length = 500

pages = total_record / page_length

i = 0
while i < pages
	Person.all.page(i).per(page_length).each do |p|
		begin
			p.save
			
			PersonRecordStatus.by_person_record_id.key(p.id).each do |s|
				s.save
			end

			PersonIdentifier.by_person_record_id.key(p.id).each do |s|
				s.save
			end

			Barcode.by_person_record_id.key(p.id).each do |s|
				s.save
			end
			puts p.id
		rescue
			puts "Error"
		end
	end
	puts i
	i = i + 1	
end
