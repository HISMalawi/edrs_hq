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
    @statuses = ["HQ CONFIRMED INCOMPLETE"]
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

    status = PersonRecordStatus.by_person_recent_status.key(params[:person_id]).last
    status.voided  = true
    status.save

    PersonRecordStatus.create(
        :person_record_id => params[:person_id],
        :district_code => status.district_code,
        :creator => @current_user.id,
        :status => params[:next_status].gsub(/\-/, ' ')
    )

    render :text => "ok"
  end

  def dispatch_printouts
    @title = "View Dispatch Printouts"
    @statuses = ["HQ DISPATCHED"]
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
        serial: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "SERIAL NUMBER"]).last.identifier rescue nil),
        den: (PersonIdentifier.by_person_record_id_and_identifier_type.key( [person.id, "DEATH ENTRY NUMBER"]).last.identifier rescue nil),
        first_name: person.first_name,
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

end
