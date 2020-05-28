class DeathRegistrationNumber< ActiveRecord::Base
	after_commit :push_to_couch
	self.table_name = "death_registration_numbers"
	def push_to_couch
		begin
			puts "Pushing records to couch"
			identifier_record = PersonIdentifier.new
	        identifier_record.person_record_id = self.person_record_id.to_s
	        identifier_record.identifier_type = "DEATH REGISTRATION NUMBER"
	        identifier_record.identifier =  self.identifier
	        identifier_record.drn_sort_value = self.id
	        identifier_record.district_code = self.district_code
	        identifier_record.save		
		rescue Exception => e
			puts "#{e}"
		end


	end

	def self.generate_drn(person)
		last_record = self.last.id rescue nil
	    drn_sort_value = last_record.to_i + 1 rescue 1
	    drn = "%010d" % drn_sort_value
	    infix = ""
	    if person.gender.match(/^F/i)
	      infix = "1"
	    elsif person.gender.match(/^M/i)
	      infix = "2"
	    end

	    drn = "#{drn[0, 5]}#{infix}#{drn[5, 9]}"

	    drn_record = self.create({
	    	death_registration_number: drn_sort_value,
	    	identifier: drn,
	    	person_record_id: person.id,
	    	district_code: person.district_code,
	    	created_at: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
	    	updated_at: Time.now.strftime('%Y-%m-%d %H:%M:%S')
	    })

	    return drn_record
	end

	def self.create_barcode(person)
	    if person.npid.blank?
	       npid = Npid.by_assigned.keys([false]).first
	       person.npid = npid.national_id
	       person.save
	    end
	    `bundle exec rails r bin/generate_barcode #{person.npid.present?? person.npid : '123456'} #{person.id} #{SETTINGS['barcodes_path']}`
	end

	def self.create_qr_barcode(person)
	    if person.npid.blank?
	       npid = Npid.by_assigned.keys([false]).first
	       person.npid = npid.national_id
	       person.save
	    end
	    `bundle exec rails r bin/generate_qr_code #{person.id} #{SETTINGS['qrcodes_path']}`    
	 end
end