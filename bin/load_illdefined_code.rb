files = ["List of Ill defined Codes.csv","Unlikely to Cause Death.csv","Codes occur in female.csv","Codes occur in male.csv"]
files.each do |file|
	CSV.foreach("#{Rails.root}/db/#{file}", :headers => true) do |row|
	  next if row[0].blank?
	  splitted = row[0].split("-")

	  if splitted.length > 1
	  	 part_a = splitted[0].gsub(".","").gsub("(","").split("")
	  	 part_b = splitted[1].gsub(".","").gsub(")","").split("")
	  	 start = part_a[3].to_i
	  	 finish = 9 
	  	 finish = part_b[3].to_i if  part_b[3].present?
	  	 
	  	 while start < finish
	  	 	if ICDCode.by_code.key("#{part_a[0,3].join("")}.#{start}").first.blank?
				ICDCode.create({code: "#{part_a[0,3].join("")}.#{start}".squish, description: row[1], category: file.gsub("List of ","").gsub(".csv","").squish })	  	 		
	  	 	end
	  	 	start = start + 1
	  	 end
	  else
	  	 if ICDCode.by_code.key(row[0].squish).first.blank?
			ICDCode.create({code: row[0].squish, description: row[1], category: file.gsub("List of ","").gsub(".csv","").squish })	  	 		
	  	 end	  	
	  end
	end	
	puts file
end
