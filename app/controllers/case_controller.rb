class CaseController < ApplicationController
  def open
    @title = "Open Cases"
    @statuses = ["DC APPROVED"]
    @page = 1

    render :template => "case/default"
  end

  def closed
    @title = "Closed Cases"
    @statuses = ["HQ CLOSED"]
    @page = 1

    render :template => "case/default"
  end

  def dispatched
    @title = "Dispatched Certificates"
    @statuses = ["HQ DISPATCHED"]
    @page = 1

    render :template => "case/default"
  end

  def conflict
    @title = "Conflict Cases"
    @statuses = ["HQ CONFLICT"]
    @page = 1

    render :template => "case/default"
  end

  def dm_reject
    @title = "Reject Incomplete Cases"
    @statuses = ["HQ INCOMPLETE"]
    @page = 1

    render :template => "case/default"
  end

  def approve_for_reprinting
    @title = "Approve for Reprinting"
    @statuses = ["DC REAPPROVED", "DC AMMENDED", "DC REPRINT"]
    @page = 1

    render :template => "case/default"
  end

  def approve_potential_duplicates
    @title = "Approve Potential Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 1

    render :template => "case/default"
  end

  def local_cases
    @title = "Local Cases"
    @statuses = ["-"]
    @page = 1

    render :template => "case/default"
  end

  def remote_cases
    @title = "Remote Cases"
    @statuses = ["HQ REJECTED"]
    @page = 1

    render :template => "case/default"
  end

  def re_open_cases
    @title = "Re-open Cases"
    @statuses = ["HQ CLOSED", "HQ DISPATCHED"]
    @page = 1

    render :template => "case/default"
  end

  def re_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ REAPPROVED"]
    @page = 1

    render :template => "case/default"
  end

  def rejected_and_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ"]
    @page = 1

    render :template => "case/default"
  end

  def approve_for_printing
    @title = "Approve for Printing"
    @statuses = ["HQ COMPLETE"]
    @page = 1

    render :template => "case/default"
  end

  def approve_reprint
    @title = "Approve for Re-printing"
    @statuses = ["HQ COMPLETE"]
    @page = 1

    render :template => "case/default"
  end

  def incomplete_cases
    @title = "Incomplete Cases"
    @statuses = ["HQ POTENTIAL INCOMPLETE"]
    @page = 1

    render :template => "case/default"
  end

  def rejected_cases
    @title = "Rejected Cases"
    @statuses = ["HQ CONFIRMED INCOMPLETE", "HQ REOPENED"]
    @page = 1

    render :template => "case/default"
  end

  def print
    @title = "Print Certificates"
    @statuses = ["HQ PRINT"]
    @page = 1

    render :template => "case/default"
  end

  def re_print
    @title = "Re-print Certificates"
    @statuses = ["HQ REPRINT"]
    @page = 1

    render :template => "case/default"
  end

  def ajax_change_status

    next_status = params[:next_status].gsub(/\-/, ' ') rescue nil
    render :text => "Error!" and return if next_status.blank?

    status = PersonRecordStatus.by_person_recent_status.key(params[:person_id]).last
    status.voided  = true
    status.save

    PersonRecordStatus.create(
        :person_record_id => params[:person_id],
        :district_code => status.district_code,
        :creator => @current_user.id,
        :status => next_status
    )

    if ["HQ PRINT", "HQ REPRINT", "HQ APPROVED", "HQ REAPPROVED"].include?(next_status)
      #generate DRN
      drn = PersonIdentifier.by_person_record_id_and_identifier_type.key([params[:person_id], "DEATH REGISTRATION NUMBER"]).last
      if drn.blank?
        PersonIdentifier.assign_drn(Person.find(params[:person_id]), @current_user.id)
      end
    end

    if next_status == "HQ COMPLETE"
      @person = Person.find(params[:person_id])
      if search_similar_record(person).count > 0

        status = PersonRecordStatus.by_person_recent_status.key(params[:person_id]).last
        status.voided  = true
        status.save

        PersonRecordStatus.create(
            :person_record_id => params[:person_id],
            :district_code => status.district_code,
            :creator => @current_user.id,
            :status => "HQ POTENTIAL DUPLICATE"
        )
      end
    end

    render :text => "ok"
  end

  def dispatch_printouts
    @title = "View Dispatch Printouts"
    @statuses = ["HQ DISPATCHED"]
    @page = 1

    render :template => "case/default"
  end

  def search_similar_record(params)
    people = []
    values = [
        params[:first_name].soundex,
        params[:last_name].soundex,
        params[:gender],
        params[:date_of_death],
        params[:birthdate],
        params[:place_of_death]]

    Person.by_demographics.key(values).each do |p|
      people << p if p.id != params.id
    end
    people
  end

  def void_cases
    @title = "Void Cases"
    @statuses = ["HQ CONFIRMED DUPLICATE"]
    @page = 1

    render :template => "case/default"
  end

  def voided_cases
    @title = "Voided Cases"
    @statuses = ["HQ VOIDED"]
    @page = 1

    render :template => "case/default"
  end

  def verify_cerfitifcates
    @title = "Verify Certificates"
    @statuses = ["HQ PRINTED", "HQ DISPATCHED"]
    @page = 1

    render :template => "case/default"
  end

  def potential
    @title = "Potential Duplicates"
    @statuses = ["HQ POTENTIAL DUPLICATE"]
    @page = 1

    render :template => "case/default"
  end


  def can_confirm
    @title = "Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 1

    render :template => "case/default"
  end

  def confirmed
    @title = "Confirmed duplicates"
    @statuses = ["HQ CONFIRMED DUPLICATE"]
    @page = 1

    render :template => "case/default"
  end


  def view_requests
    @title = "View Dispatch Printouts"
    @statuses = ["DC AMMEND"]
    @page = 1

    render :template => "case/default"
  end

  def more_open_cases
    keys = []
    ((params[:statuses].split("|") rescue []) || []).each{|status|
      next if status.blank?
      keys << status.gsub(/\_/, " ").upcase
    }
    
    
    cases = []
    
    (PersonRecordStatus.by_record_status.keys(keys).page(params[:page_number]).per(10) || []).each do |status|
      
      person = status.person
     
      cases << {
        drn: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH REGISTRATION NUMBER"]).last.identifier rescue nil),
        den: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH ENTRY NUMBER"]).last.identifier rescue nil),
        first_name: person.first_name,
        middle_name:  person.middle_name,
        last_name:  person.last_name,
        dob:        person.birthdate.strftime("%d/%b/%Y"),
        gender:     person.gender,
        person_id:  person.id
      }
    end 

    render text: cases.to_json and return
  end

  def view_cases

    @person = Person.find(params[:person_id])

    @statuses = [PersonRecordStatus.by_person_recent_status.key(@person.id).last.status]

    @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

    @person_place_details = place_details(@person)

  end


  def search_similar_record(person)

    values = [person.first_name.soundex,
              person.last_name.soundex,
              params[:gender],
              params[:birthdate],
              params[:date_of_death],
              params[:place_of_death]
    ]

    people = Person.by_demographics.key(values).each

    if people.count == 0

      render :text => {:response => false}.to_json
    else

      render :text => {:response => people}.to_json
    end
  end

end
