class PersonIdentifier < CouchRest::Model::Base

  before_save :set_site_code,:set_distict_code,:set_check_digit
  after_create :insert_update_into_mysql
  after_save :insert_update_into_mysql
  cattr_accessor :can_assign_den
  cattr_accessor :can_assign_drn

  property :person_record_id, String
  property :identifier_type, String #Entry Number|Registration Number|Death Certificate Number| National ID Number
  property :identifier, String
  property :check_digit
  property :site_code, String
  property :den_sort_value, Integer
  property :drn_sort_value, Integer
  property :district_code, String
  property :creator, String
  property :_rev, String

  timestamps!

  unique_id :identifier

  design do
    view :by__id
    view :by_person_record_id
    view :by_identifier_type
    view :by_identifier
    view :by_identifier_and_identifier_type
    view :by_site_code
    view :by_drn_sort_value,
         :map => "function(doc) {
                  if ((doc['type'] == 'PersonIdentifier')) {
                    emit(doc['drn_sort_value']);
                  }
                }"
    view :by_district_code
    view :by_creator
    view :by_created_at
    view :by_updated_at
    view :by_person_record_id_and_identifier_type
    filter :district_sync, "function(doc,req) {return req.query.district_code == doc.district_code}"
    filter :facility_sync, "function(doc,req) {return req.query.site_code == doc.site_code}"
  end

  def person
    person = Person.find(self.person_record_id)
    return person
  end

  def set_creator
    self.creator =  User.current_user.id
  end

  def set_check_digit
    self.check_digit =  PersonIdentifier.calculate_check_digit(self.identifier)
  end

  def set_site_code
    if CONFIG['site_type'] == "facility"
      self.site_code = self.person.facility_code rescue nil
    else
      self.site_code = nil
    end
  end

  def set_distict_code
    if self.person.district_code.present?
      self.district_code = self.person.district_code
    else
      raise self.person.inspect
    end
    
  end

  def self.calculate_check_digit(serial_number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    number = serial_number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2!=parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end

    check_digit = (9 * sum) % 10

    return check_digit
  end

  def self.generate_drn(person)
    last_record = PersonIdentifier.by_drn_sort_value.last.drn_sort_value rescue nil
    drn_sort_value = last_record.to_i + 1 rescue 1
    nat_serial_num = drn_sort_value
    drn = "%010d" % drn_sort_value
    infix = ""
    if person.gender.match(/^F/i)
      infix = "1"
    elsif person.gender.match(/^M/i)
      infix = "2"
    end

    drn = "#{drn[0, 5]}#{infix}#{drn[5, 9]}"
    return drn, nat_serial_num
  end

  def self.assign_drn(person, creator)

    drn_record = DeathRegistrationNumber.where(person_record_id: person.id).first

    if drn_record.blank?
      begin
        drn_record = DeathRegistrationNumber.generate_drn(person)
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
        status = PersonRecordStatus.by_person_recent_status.key(person.id.to_s).last

        if status.present?
           status.update_attributes({:voided => true})
        end
        
        if PersonRecordStatus.nextstatus.present? && PersonRecordStatus.nextstatus[person.id].present?
          record_status = PersonRecordStatus.nextstatus[person.id]
        end
        
        record_status = "HQ CAN PRINT" if record_status.blank?
        PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => record_status,
                                  :prev_status => status.status,
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
        status = PersonRecordStatus.by_person_recent_status.key(person.id.to_s).last

        if status.present?
           status.update_attributes({:voided => true})
        end
        
        if PersonRecordStatus.nextstatus.present? && PersonRecordStatus.nextstatus[person.id].present?
          record_status = PersonRecordStatus.nextstatus[person.id]
        end
        
        record_status = "HQ CAN PRINT" if record_status.blank?
        PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => record_status,
                                  :prev_status => status.status,
                                  :district_code => person.district_code,
                                  :creator => creator,
                                  :comment => "Approved record at HQ"})

        PersonRecordStatus.nextstatus.delete(person.id) if PersonRecordStatus.nextstatus.present?
        
        person.update_attributes({:approved =>"Yes",:approved_at=> (drn_record.created_at.to_time rescue Time.now)})
    end
  end

  def insert_update_into_mysql
      fields  = self.keys.sort
      sql_record = RecordIdentifier.where(person_identifier_id: self.id).first
      sql_record = RecordIdentifier.new if sql_record.blank?
      fields.each do |field|
        next if field == "type"
        next if field == "_rev"
        if field =="_id"
            sql_record["person_identifier_id"] = self[field]
        else
            sql_record[field] = self[field]
        end

      end
      sql_record.save
  end

  def self.create_barcode(person)
    if person.npid.blank?
       npid = Npid.by_assigned.keys([false]).first
       person.npid = (npid.national_id rescue "")
       person.save
    end
    `bundle exec rails r bin/generate_barcode #{person.npid.present?? person.npid : '123456'} #{person.id} #{SETTINGS['barcodes_path']}`
  end

  def self.create_qr_barcode(person)
    if person.npid.blank?
       npid = Npid.by_assigned.keys([false]).first
       person.npid = (npid.national_id rescue "")
       person.save
    end
    `bundle exec rails r bin/generate_qr_code #{person.id} #{SETTINGS['qrcodes_path']}`    
  end
end
