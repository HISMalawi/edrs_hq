class AssignDrn
  include SuckerPunch::Job
  workers 1

  def perform()
    queue = PersonRecordStatus.by_marked_for_hq_approval.each
    job_interval = CONFIG['ben_assignment_interval']
    job_interval = 1.5 if job_interval.blank?
    job_interval = job_interval.to_f

    FileUtils.touch("#{Rails.root}/public/sentinel")

    if Rails.env = 'development' || queue.count > 0
      SuckerPunch.logger.info "Approving for printing #{queue.count} record(s)"
    end
    queue.each do |record|
        person = record.person
        status = PersonRecordStatus.by_person_recent_status.key(record.person_record_id.to_s).last

        status.update_attributes({:voided => true})
        PersonIdentifier.assign_drn(person, record.creator)
        PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => (PersonRecordStatus.nextstatus[person.id] rescue "HQ PRINT"),
                                  :district_code => (person.district_code rescue CONFIG['district_code']),
                                  :creator => record.creator})
        PersonRecordStatus.nextstatus.delete(person.id)
        person.update_attributes({:approved =>"Yes",:approved_at=> (Time.now)})

        Audit.create(record_id: record.id,
                       audit_type: "Audit",
                       user_id: record.creator,
                       level: "Person",
                       reason: "Approved record at HQ")

        #checkCreatedSync(record.id, "HQ OPEN", record.request_status)

        SuckerPunch.logger.info "#{record.id} => #{record.district_id_number}"
    end rescue (AssignDrn.perform_in(job_interval))

    AssignDrn.perform_in(job_interval)
  end
end
