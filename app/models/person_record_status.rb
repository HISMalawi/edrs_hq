class PersonRecordStatus < CouchRest::Model::Base

	before_save :set_district_code,:set_facility_code,:set_registration_type
	after_create :insert_update_into_mysql,:create_audit
	after_save :insert_update_into_mysql
	after_destroy :delete_from_mysql
	cattr_accessor :nextstatus

	property :person_record_id, String
	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...
	property :prev_status, String
	property :district_code, String
	property :facility_code, String
	property :comment, String
	property :voided, TrueClass, :default => false
	property :reprint, TrueClass, :default => false
	property :registration_type, String
	property :creator, String

	timestamps!

	design do 
		view :by_status
		view :by_distrit_code
		view :by_creator
		view :by_created_at
		view :by_updated_at
		view :by_person_record_id
		view :by_registration_type_and_status
		view :by_registration_type_and_district_code_and_status
		view :by_person_record_id_and_status
	    view :by_person_recent_status,
				 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit(doc['person_record_id'], 1);
	                  }
	                }"

		view :by_record_status,
	         	 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit(doc['status'], 1);
	                  }
	                }"

	    view :by_district_code_and_record_status,
	    			 :map => "function(doc) {
	                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false) {

	                    	emit([doc['district_code'],doc['status']], 1);
	                  }
	                }"
	                
	    view :by_marked_for_hq_approval,
	    		:map => "function(doc){
	    					 if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false && doc['status']=='MARKED HQ APPROVAL'){
		                    	emit(doc['status'], 1);
		                  	}
	    				}"	
	    view :by_amend_or_reprint,
	    		:map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['reprint'] == true){
		                    	emit(doc['status'], 1);
		                  	}
	    			   }"
	    view :by_status_and_created_at
	    view :by_record_status_and_created_at,
	    	  :map =>"function(doc){
		    			   if (doc['type'] == 'PersonRecordStatus' && doc['voided'] == false){
		                    	emit(doc['status'] +'_'+doc['created_at'], 1);
		                  	}
	    			   }"
		               
	    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
	    filter :facility_sync, "function(doc,req) {return req.query.facility_code == doc.facility_code}"
	    filter :stats_sync, "function(doc,req) {return doc.district_code != null}"

	end

	def set_district_code
		self.district_code = self.person.district_code
	end

	def set_facility_code
		if self.person.facility_code.present?
			self.facility_code = self.person.facility_code
		else
			self.facility_code = nil
		end
	end

	def set_registration_type
		if self.person.registration_type.present?
			self.registration_type = self.person.registration_type
		else
			self.registration_type = "Normal Cases"
		end		
	end

	def person
	    return Person.find(self.person_record_id)    	
	end

	def self.change_status(person,currentstatus,comment=nil)

		new_status = PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :comment => comment,
                                  :district_code => person.district_code,
                                  :creator => (User.current_user.id rescue nil)})

      	PersonRecordStatus.by_person_recent_status.key(person.id).each.sort_by{|d| d.created_at}.each do |s|
	        next if s === new_status
	        s.voided = true
	        s.save
      	end

		lock = MyLock.by_person_id.key(person.id).last
		if lock.present? 
			lock.destroy
		end
	end

	def self.change_status(person,currentstatus,comment=nil)

		new_status = PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => currentstatus,
                                  :comment => comment,
                                  :district_code => person.district_code,
                                  :creator => (User.current_user.id rescue nil)})

      PersonRecordStatus.by_person_recent_status.key(person.id).each.sort_by{|d| d.created_at}.each do |s|
        next if s === new_status
        s.voided = true
        s.save
      end	
	end

	def insert_update_into_mysql
	    fields  = self.keys.sort
	    sql_record = RecordStatus.where(person_record_status_id: self.id).first
	    sql_record = RecordStatus.new if sql_record.blank?
	    fields.each do |field|
	      next if field == "type"
	      next if field == "_rev"
	      if field =="_id"
	          sql_record["person_record_status_id"] = self[field]

	      elsif field =="voided"
	      		if self[field] == true
	      			sql_record[field] = 1
	      		else
	      			sql_record[field] = 0
				end
		  elsif field == "reprint"
			if self[field] == true
				sql_record[field] = 1
			else
				sql_record[field] = 0
			end
	      else
	          sql_record[field] = self[field]
	      end
		end
		if self["reprint"].blank?
			sql_record["reprint"] = 0
		end
	    sql_record.save
	end


	def delete_from_mysql
		sql_record = RecordStatus.where(person_record_status_id: self.id).first
		if sql_record.present?
			sql_record.destroy
		end
	end

	def create_audit
              Audit.create({
                                    :record_id  => self.person_record_id,
                                    :audit_type => "Status Change",
                                    :reason     => self.comment,
                                    :previous_value => self.prev_status,
                                    :current_value => self.status
              })		
		
	end
end
