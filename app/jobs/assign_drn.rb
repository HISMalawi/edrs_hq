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
      SuckerPunch.logger.info "Approving for printing #{queue.count} record(s)"
    end
    queue.each do |record|
        person = record.person

        PersonIdentifier.assign_drn(person, record.creator)
        #checkCreatedSync(record.id, "HQ OPEN", record.request_status)

        SuckerPunch.logger.info "#{record.id} => #{record.district_id_number}"
    end rescue (AssignDrn.perform_in(job_interval))

    AssignDrn.perform_in(job_interval)
  end
end
