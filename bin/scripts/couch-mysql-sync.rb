require "rails"
require "rest-client"
require "yaml"


couch_path = Dir.pwd + "/config/couchdb.yml"
couch_settings = YAML.load_file(couch_path)
couch_db_settings = couch_settings[Rails.env]

cseq = CouchdbSequence.last
seq = cseq.seq rescue nil
if cseq.blank?
  CouchdbSequence.create(seq: 0)
end

seq = 0 if seq.blank?

couchdatabase = "#{couch_db_settings['prefix']}#{couch_db_settings['suffix'].present? ? '_'+couch_db_settings['suffix'] : ''}"

changes_link = "#{couch_db_settings['protocol']}://#{couch_db_settings['username']}:#{couch_db_settings['password']}@#{couch_db_settings['host']}:#{couch_db_settings['port']}/#{couchdatabase}/_changes?include_docs=true&limit=500&since=#{seq}"


data = JSON.parse(RestClient.get(changes_link))

(data['results'] || []).each do |result|
  seq = result['seq']
  next unless ['Person','PersonRecordStatus','PersonIdentifier'].include?(result['doc']['type'])
  begin
  	 CouchDBToMysql.insert_or_update(result['doc'], seq)
  rescue Exception => e
  	 cseq = CouchdbSequence.last
     cseq.seq =  seq.to_i
     cseq.save
  end
  
end

