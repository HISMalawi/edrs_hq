class AssignDrn
  include SuckerPunch::Job
  workers 1

  def perform()
    queue = PersonRecordStatus.by_marked_for_hq_approval.each
    job_interval = CONFIG['drn_assignment_interval']
    job_interval = 1.5 if job_interval.blank?
    job_interval = job_interval.to_f

    FileUtils.touch("#{Rails.root}/public/sentinel")

    if Rails.env = 'development' || queue.count > 0
      #SuckerPunch.logger.info "Approving for printing #{queue.count} record(s)"
    end
    queue.each do |record|
        person = record.person
        SuckerPunch.logger.info "Approving for printing#{person.id}  #{person.drn} Before Skip"
        if person.drn.present?
                status = PersonRecordStatus.by_person_recent_status.key(person.id.to_s).last
                PersonRecordStatus.by_person_recent_status.key(person.id.to_s).each do |status|
                   status.update_attributes({:voided => true})
                end
                PersonRecordStatus.create({
                                          :person_record_id => person.id.to_s,
                                          :status => "HQ CAN PRINT",
                                          :prev_status => status.status,
                                          :district_code => person.district_code,
                                          :creator => record.creator,
                                          :comment => "Approved record at HQ"})
                
                person.update_attributes({:approved =>"Yes",:approved_at=>  Time.now})                           
        end
        PersonIdentifier.assign_drn(person, record.creator)
        #sleep(0.2)
        #checkCreatedSync(record.id, "HQ OPEN", record.request_status)
        SuckerPunch.logger.info "#{record.id} => #{record.district_id_number}"
    end rescue (AssignDrn.perform_in(job_interval))

    AssignDrn.perform_in(job_interval)
  end
end
