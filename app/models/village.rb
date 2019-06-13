require 'couchrest_model'

class Village < CouchRest::Model::Base

  property :ta_id, String
  property :name, String
  
  timestamps!

  design do
      view :by__id
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = VillageRecord.where(village_id: self.id).first
      sql_record = VillageRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["village_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end
end