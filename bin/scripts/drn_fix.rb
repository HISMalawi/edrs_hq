create_drn_table = "CREATE TABLE IF NOT EXISTS death_registration_numbers (
                            death_registration_number int NOT NULL AUTO_INCREMENT ,
                            identifier varchar(50) NOT NULL,
                            district_code varchar(5) NOT NULL,
              							person_record_id varchar(255) NOT NULL UNIQUE,
                            created_at datetime DEFAULT NULL,
                            updated_at datetime DEFAULT NULL,
                            PRIMARY KEY (death_registration_number)
                    ) ENGINE=InnoDB DEFAULT CHARSET=latin1;"

SimpleSQL.query_exec(create_drn_table);

count = PersonIdentifier.by_identifier_type.key("DEATH REGISTRATION NUMBER").count
pagesize = 200
pages = (count / pagesize) + 1

page = 0

while page <= pages
  PersonIdentifier.by_identifier_type.key("DEATH REGISTRATION NUMBER").page(page).per(200).each do |identifier|
    next if identifier.identifier_type != "DEATH REGISTRATION NUMBER"
    sql = "INSERT INTO death_registration_numbers(death_registration_number, identifier, district_code,person_record_id,created_at,updated_at) 
           VALUES(#{identifier.drn_sort_value},'#{identifier.identifier}', '#{identifier.district_code}','#{identifier.person_record_id}',
           '#{identifier.created_at.to_time.strftime('%Y-%m-%d %H:%M:%S')}','#{identifier.updated_at.to_time.strftime('%Y-%m-%d %H:%M:%S')}')"

    SimpleSQL.query_exec(sql);
  end
  page = page + 1
end