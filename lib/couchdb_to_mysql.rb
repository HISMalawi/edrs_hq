class CouchDBToMysql
	def self.doc_model_map(doc_type)
		map = {
				"Person"  => {:model=>"Record", :id => "person_id"},
				"PersonRecordStatus"=> {:model => "RecordStatus" , :id => "person_record_status_id"},
				"PersonIdentifier" => {:model=>"RecordIdentifier",:id => "person_identifier_id"}
		}

		return map[doc_type]
	end

	def self.insert_or_update(doc, seq)
		couch_record = eval(doc['type']).find(doc['_id'])
		record = eval(self.doc_model_map(doc['type'])[:model]).find(doc['_id'])
		data = couch_record.as_json
		rejected_keys = ['type']
		rejected_keys.each do |key|
			data.delete(key)
		end
		
		if record.present?
          record.update_columns(data)
          cseq = CouchdbSequence.last
          cseq.seq =  seq.to_i
          cseq.save
        else
          record =  eval(self.doc_model_map(doc['type'])[:model]).new(data)
          query = record.class.arel_table.create_insert.tap { |im| im.insert(record.send(
                                                                                 :arel_attributes_with_values_for_create,
                                                                                 record.attribute_names)) }.to_sql
          ActiveRecord::Base.connection.execute(<<-EOQ)
				#{query}
          EOQ
          cseq = CouchdbSequence.last
          cseq.seq =  seq.to_i
          cseq.save
		end
	end
end
