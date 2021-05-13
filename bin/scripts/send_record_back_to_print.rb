RecordStatus.where("status='HQ PRINTED' AND DATE_FORMAT(created_at,'%Y-%m-%d') >='2021-05-10' AND DATE_FORMAT(created_at,'%Y-%m-%d') <='2021-05-10'").each do |d|
    can_print = RecordStatus.where(person_record_id: d.person_record_id, status:'HQ CAN PRINT').last
    can_print_couch = PersonRecordStatus.find(can_print.person_record_status_id)
    can_print_couch.voided = false
    can_print_couch.save
    a = PersonRecordStatus.find(d.person_record_status_id)
    a.destroy
    d.destroy
end
