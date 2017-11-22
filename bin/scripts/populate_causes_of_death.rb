require 'rails'
i = 0
def concatinate(array)
	return array.join(" ");
end
File.open("#{Rails.root}/app/assets/data/icd10cm_codes_2017.txt", "r").each_line do |line|

	parts = line.split(" ")
	code = parts[0]
	description =  concatinate(parts - ["#{parts[0]}"])

	ICDCode.create(code: code, description: description)
	puts "#{code} : #{description}"

	sleep 0.3

	i = i + 1
end