class RecordIdentifier < ActiveRecord::Base
	after_commit :push_to_couchDB
	before_create :set_id
	self.table_name = "person_identifier"
	def person
		return Record.find(self.person_record_id)
	end
	def set_id
		self.person_identifier_id = SecureRandom.uuid
	end
	def push_to_couchDB
		data =  Pusher.database.get(self.id) rescue {}
		
		self.as_json.keys.each do |key|
			next if key == "_rev"
			next if key =="_deleted"
			if key == "person_identifier_id"
			 	data["_id"] = self.as_json[key]
			else
			 	data[key] = self.as_json[key]
			end
			if data["type"].nil?
				data["type"] = "PersonIdentifier"
			end
		end
		
		return  Pusher.database.save_doc(data)

	end

	def self.assign_drn(person, creator)

		drn_record = DeathRegistrationNumber.where(person_record_id: person.id).first
	
		if drn_record.blank?
		  begin
			drn_record = DeathRegistrationNumber.generate_drn(person)
			drn_record.save
			if SETTINGS['print_qrcode']
				if !File.exist?("#{SETTINGS['qrcodes_path']}QR#{person.id}.png")
				  self.create_qr_barcode(person)
				sleep(1)
				end
			else
			  if !File.exist?("#{SETTINGS['barcodes_path']}#{person.id}.png")
				  self.create_barcode(person)
				sleep(1)
			  end         
			end
			status = RecordStatus.where(person_record_id:person.id , voided: 0).limit(5).order("created_at DESC").first
	
			if status.present?
			   status.voided = 1
			   status.save
			end
			
			if PersonRecordStatus.nextstatus.present? && PersonRecordStatus.nextstatus[person.id].present?
			  record_status = PersonRecordStatus.nextstatus[person.id]
			end
			
			record_status = "HQ CAN PRINT" if record_status.blank?
			RecordStatus.create({
									  :person_record_id => person.id.to_s,
									  :status => record_status,
									  :prev_status => (status.status rescue nil),
									  :district_code => person.district_code,
									  :creator => creator,
									  :comment => "Approved record at HQ"})
	
			PersonRecordStatus.nextstatus.delete(person.id) if PersonRecordStatus.nextstatus.present?
			
			person.update_attributes({:approved =>"Yes",:approved_at=> (drn_record.created_at.to_time rescue Time.now)})
		  rescue Exception => e
			log = "#{Rails.root}/log/approval_failure.txt"
			`echo "\n" >> #{log}`
			`echo "#{person.id.to_s} => #{e.message}" >> #{log}`
			`echo "\n" >> #{log}`
			PersonRecordStatus.change_status(person,"MARKED HQ APPROVAL")     
		  end
		else
			status = RecordStatus.where(person_record_id:person.id , voided: 0).limit(5).order("created_at DESC").first
	
			if status.present?
			   status.voided = 1
			   status.save
			end
			
			if PersonRecordStatus.nextstatus.present? && PersonRecordStatus.nextstatus[person.id].present?
			  record_status = PersonRecordStatus.nextstatus[person.id]
			end
			
			record_status = "HQ CAN PRINT" if record_status.blank?
			RecordStatus.create({
									  :person_record_id => person.id.to_s,
									  :status => record_status,
									  :prev_status => (status.status rescue nil) ,
									  :district_code => person.district_code,
									  :creator => creator,
									  :comment => "Approved record at HQ"})
	
			PersonRecordStatus.nextstatus.delete(person.id) if PersonRecordStatus.nextstatus.present?
			
			person.update_attributes({:approved =>"Yes",:approved_at=> (drn_record.created_at.to_time rescue Time.now)})
		end
	  end
end
