	# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "Initializing default user"
user = User.find('admin')
if user.blank?
	user = User.new()
	user.username = "admin"
	user.plain_password = "password"
	user.first_name = "EDRS"
	user.last_name = "Administrator"
	user.role = "admin"
	user.email = "admin@baobabhealth.org"
	user.save
  puts "User created succesfully!"
else
  puts "User already exists"
end

puts "Users count : #{User.all.count}"

File.open("#{Rails.root}/app/assets/data/facilities.txt").readlines.each{|f| h = f.strip.split("|"); Hospital.create(hospital_id: h[0], region: h[1], district: h[2], lon: h[3], lat: h[4]) if Hospital.find(h[0]).blank?}

puts "Initialising health facilities"

CSV.foreach("#{Rails.root}/app/assets/data/health_facilities.csv", :headers => true) do |row|
 next if row[0].blank?
 health_facility = HealthFacility.find(row[0])
 
 if health_facility.blank?
    health_facility = HealthFacility.new()
    health_facility.facility_code = row[0]  
    health_facility.name = row[1]
    health_facility.short_name = row[2]
    health_facility.district = row[3]
    health_facility.save!
    puts "Health facility initialised succesfully!"
 else
    puts "Healthy facility already exists"
 end
        
end
puts "Health facilities count : #{HealthFacility.all.count}"

puts "Initialising Districts"

CSV.foreach("#{Rails.root}/app/assets/data/districts_with_codes.csv", :headers => true) do |row|
 next if row[0].blank?
 district = District.find(row[0])
 
 if district.blank?
    district = District.new()
    district.district_code = row[0]  
    district.name = row[1]
    district.save!
    puts "District initialised succesfully!"
 else
    puts "District already exists"
 end
        
end
puts "Districts count : #{District.all.count}"

CSV.foreach("#{Rails.root}/app/assets/data/nationality.txt", :headers => false) do |row|
 next if row[0].blank?
 nationality = Nationality.find(row[0])
 
 if nationality.blank?
    nationality = Nationality.new()
    nationality.nationality = row[0]  
    nationality.save!
    puts "Nationality initialised succesfully!"
 else
    puts "Nationality already exists"
 end
        
end

