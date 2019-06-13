class Role < CouchRest::Model::Base
  property :role, String
  property :level, String
  property :activities, []
  design do
    view :by__id
  end
  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = RoleRecord.where(role_id: self.id).first
      sql_record = RoleRecord.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["role_id"] = self[field]

        elsif field =="activities"
              sql_record[field] = self[field].join(",")
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end

end
