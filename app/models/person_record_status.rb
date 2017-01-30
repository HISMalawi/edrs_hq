class PersonRecordStatus < CouchRest::Model::Base

	property :person_record_id, String

	property :status, String #DC Active|HQ Active|HQ Approved|Printed|Reprinted...

	property :district_code, String

	property :voided, TrueClass, :default => false

	property :creator, String

	timestamps!

	design do 

		view :by_status

		view :by_district_code

		view :by_voided

		view :by_creator

    view :by_person_recent_status,
         :map => "function(doc) {
                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] ==false) {

                    	emit(doc['person_record_id'], 1);
                  }
                }"

    view :by_record_status,
         	 :map => "function(doc) {
                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] ==false) {

                    	emit(doc['status'], 1);
                  }
                }"

    view :by_record_status_and_created_at,
         :map => "function(doc) {
                  if (doc['type'] == 'PersonRecordStatus' && doc['voided'] ==false) {
                      var date = new Date(doc['created_at']);
                      var year = date.getFullYear();
                      var month = date.getMonth() + 1;
                      var day = date.getDate();
                      var str = '' + year + '-' + (month > 9 ? month : ('0' + month)) + '-' + (day > 9 ? day : ('0' + day));
                    	emit(doc['status'] + '_' + str, 1);
                  }
                }"

	end

	def person

    	   return Person.find(self.person_record_id)
    	
        end
end
