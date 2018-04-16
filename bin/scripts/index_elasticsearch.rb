puts "Indexing done"
people_count = Person.count

page_number = 0
page_size = 100

pages = people_count / page_size

(0..pages).each do |page|
    Person.by__id.page(page).per(page_size).each do |person|
        if SETTINGS["potential_duplicate"]
              record = {}
              record["first_name"] = person.first_name
              record["last_name"] = person.last_name
              record["middle_name"] = (person.middle_name rescue nil)
              record["gender"] = person.gender
              record["place_of_death_district"] = person.place_of_death_district
              record["birthdate"] = person.birthdate
              record["date_of_death"] = person.date_of_death
              record["mother_last_name"] = (person.mother_last_name rescue nil)
              record["mother_middle_name"] = (person.mother_middle_name rescue nil)
              record["mother_first_name"] = (person.mother_first_name rescue nil)
              record["father_last_name"] = (person.father_last_name rescue nil)
              record["father_middle_name"] = (person.father_middle_name rescue nil)
              record["father_first_name"] = (person.father_first_name rescue nil)
              record["id"] = person.id
              record["district_code"] = person.district_code
              begin
                  SimpleElasticSearch.add(record)
                  sleep 0.1
              rescue Exception => e
                  
              end

        else
          next
        end
    end
    puts "Indexed #{(page + 1) * page_size}"
end

puts "Data to mysql"
`bundle exec rake edrs:build_mysql`

puts "Update couch sequence"
couch_mysql_path =  "#{Rails.root}/config/couchdb.yml"
db_settings = YAML.load_file(couch_mysql_path)
couch_db_settings =  db_settings[Rails.env]
couch_protocol = couch_db_settings["protocol"]
couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]
changes_link = "#{couch_protocol}://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}/_changes"
data = JSON.parse(RestClient.get(changes_link))
if data.present?
        couchdb_sequence = CouchdbSequence.create(seq: data["last_seq"].to_i)
end

puts "Migration done"