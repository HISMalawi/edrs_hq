require 'open3'


site_ips = {
  "MN" => {"host" => "172.28.1.200", "port"=>"5984"},
  "NE" => {"host" => "172.23.2.200", "port" => "5984"},
  "CK" => {"host" => "172.24.8.200", "port" => "5984"},
  "CZ" => {"host" => "172.25.23.210", "port" => "5984"},
  "PE" => {"host" => "172.31.1.210", "port" => "5984"},
  "NN" => {"host" => "172.24.1.200", "port" => "5984"},
  "TO" => {"host" => "172.26.13.200", "port" => "5984"},
  "MHG" => {"host" => "172.29.8.220", "port" => "5984"},
  "MH" => {"host" => "172.22.1.200", "port" => "5984"},
  "MJ" => {"host" => "172.26.11.210", "port" => "5984"},
  "BLK" => {"host" => "172.29.1.200", "port" => "5984"},
  "ZA" => {"host" => "172.17.133.200", "port" => "5984"},
  "BT" => {"host" => "172.25.17.3", "port" => "5984"}

}

db_settings = YAML.load_file("#{Rails.root}/config/couchdb.yml")
couch_db_settings =  db_settings[Rails.env]

couch_username = couch_db_settings["username"]
couch_password = couch_db_settings["password"]
couch_host = couch_db_settings["host"]
couch_db = couch_db_settings["prefix"] + (couch_db_settings["suffix"] ? "_" + couch_db_settings["suffix"] : "" )
couch_port = couch_db_settings["port"]


DistrictRecord.all.each do |d|
  next if d.name.include?("City")
  puts d.id
  next if Online.find("#{d.id}SYNC").present?
  json = {}
  json["_id"] = "#{d.id}SYNC"
  json["ip"] = (site_ips[d.id]["host"] rescue "0.0.0.0")
  json["port"] = (site_ips[d.id]["port"] rescue "5984")
  json["district_code"] = d.id
  json["false"] = false
  json["type"] = "Online"
  json["time_seen"] = (Time.now - 7.days).strftime('%Y-%m-%d %H:%M:%S')
  json["created_at"] = (Time.now - 7.days).strftime('%Y-%m-%d %H:%M:%S')
  json["updated_at"] = (Time.now - 7.days).strftime('%Y-%m-%d %H:%M:%S')
  begin
        RestClient.post("http://#{couch_username}:#{couch_password}@#{couch_host}:#{couch_port}/#{couch_db}", json.to_json, {content_type: :json, accept: :json})
        puts json
  rescue RestClient::ExceptionWithResponse => err
          puts  err.response.inspect
  end

end


def is_up?(host)
    host, port = host.split(':')
    a, b, c = Open3.capture3("nc -vw 5 #{host} #{port}")
    b.scan(/succeeded/).length > 0
end

Online.all.each do |d|
	online = is_up?("#{d.ip}:#{d.port}") rescue false

  if online
    d.online = true
    d.time_seen = Time.now
    d.save
  else
    d.online = false
    d.save
  end
end