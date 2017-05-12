class CaseController < ApplicationController
  def open
    @title = "Open Cases"
    @statuses = ["DC APPROVED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def closed
    @title = "Closed Cases"
    @statuses = ["HQ CLOSED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def dispatched
    @title = "Dispatched Certificates"
    @statuses = ["HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def conflict
    @title = "Conflict Cases"
    @statuses = ["HQ CONFLICT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def hq_incomplete
    @title = "Reject Incomplete Cases"
    @statuses = ["HQ INCOMPLETE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_for_reprinting
    @title = "Approve for Reprinting"
    @statuses = ["DC REAPPROVED", "DC AMENDED", "DC REPRINT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def corrected_from_dc
    @title = "Corrected from DC"
    @statuses = ["DC REAPPROVED"]
    @page = 1
    session[:return_url] = request.path
    render :template => "case/default"
  end

  def approve_potential_duplicates
    @title = "Approve Potential Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def local_cases
    @title = "Local Cases"
    @statuses = ["-"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def remote_cases
    @title = "Remote Cases"
    @statuses = ["HQ REJECTED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_open_cases
    @title = "Re-open Cases"
    @statuses = ["HQ CLOSED", "HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ REAPPROVED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def rejected_and_approved_cases
    @title = "Re-Approved Cases"
    @statuses = ["HQ"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_for_printing
    @title = "Approve for Printing"
    @statuses = ["HQ COMPLETE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approve_reprint
    @title = "Approve for Re-printing"
    @statuses = ["HQ COMPLETE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def incomplete_cases
    @title = "Incomplete Cases"
    @statuses = ["HQ POTENTIAL INCOMPLETE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def rejected_cases
    @title = "Rejected Cases"
    @statuses = ["HQ CONFIRMED INCOMPLETE", "HQ REOPENED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def print
    @title = "Print Certificates"
    @statuses = ["HQ PRINT","HQ PRINT AMEND","HQ REPRINT REQUEST"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def re_print
    @title = "Re-print Certificates"
    @statuses = ["HQ REPRINT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def approved_for_print_marked_incomplete
    @title = "Marked incomplete but approved for print"
    @prev_status = "HQ INCOMPLETE"
    @status = "HQ PRINT"
    @statuses = ["HQ PRINT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def reprinted_certificates
    @title = "Re printed Certificates"
    @prev_status = "HQ REPRINT"
    @status = "HQ CLOSED"
    @statuses = ["HQ CLOSED","HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def ajax_change_status

    next_status = params[:next_status].gsub(/\-/, ' ') rescue nil
    render :text => "Error!" and return if next_status.blank?
    person = Person.find(params[:person_id])
    
    if ["HQ PRINT", "HQ REPRINT", "HQ APPROVED", "HQ REAPPROVED"].include?(next_status)
      drn = PersonIdentifier.by_person_record_id_and_identifier_type.key([params[:person_id], "DEATH REGISTRATION NUMBER"]).last
      if drn.blank?
        last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
        job_interval = CONFIG['ben_assignment_interval']
        job_interval = 1.5 if job_interval.blank?
        job_interval = job_interval.to_f
        now = Time.now
        if (now - last_run_time).to_f > job_interval
          AssignDrn.perform_in(1)
        end

        if PersonRecordStatus.nextstatus.present?
           PersonRecordStatus.nextstatus[params[:person_id]] = next_status
        else
          PersonRecordStatus.nextstatus = {}
          PersonRecordStatus.nextstatus[params[:person_id]] = next_status
        end
        potential_duplicate =  potential_duplicate_full_text?(person)
        
        if potential_duplicate.blank?
          PersonRecordStatus.change_status(Person.find(params[:person_id]),"MARKED HQ APPROVAL")
          render :text => "ok" and return
        else
          existing = []
          ids = []
          duplicate.each do |dup| 
            if dup[0] != params[:id]
              existing << dup
              ids << dup[0]
            end
          end
          change_log = [{:duplicates => ids.to_s}]
          Audit.create({
                      :record_id  => person.id.to_s,
                      :audit_type => "POTENTIAL DUPLICATE",
                      :reason     => "Record is a potential",
                      :change_log => change_log
             })
          PersonRecordStatus.change_status(Person.find(params[:person_id]),"HQ POTENTIAL DUPLICATE")
          render :text => "duplicate" and return
        end
      end
    end

    status = PersonRecordStatus.by_person_recent_status.key(params[:person_id]).last
    status.voided  = true
    status.save

    PersonRecordStatus.create(
        :person_record_id => params[:person_id],
        :district_code => person.district_code,
        :creator => @current_user.id,
        :prev_status => status.status,
        :status => next_status
    )

    if next_status == "HQ COMPLETE"
      @person = Person.find(params[:person_id])
      if ((search_similar_record(@person).count > 1) rescue false)

        status = PersonRecordStatus.by_person_recent_status.key(params[:person_id]).last
        status.voided  = true
        status.save

        PersonRecordStatus.create(
            :person_record_id => params[:person_id],
            :district_code => person.district_code,
            :prev_status => status.status,
            :creator => @current_user.id,
            :status => "HQ POTENTIAL DUPLICATE"
        )
      end
    end

    render :text => "ok" and return
  end

  def dispatch_printouts
    @title = "View Dispatch Printouts"
    @statuses = ["HQ DISPATCHED"]
    session[:return_url] = request.path

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
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def voided_cases
    @title = "Voided Cases"
    @statuses = ["HQ VOIDED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def verify_cerfitificates
    @title = "Verify Certificates"
    @statuses = ["HQ PRINTED", "HQ DISPATCHED"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def potential
    @title = "Potential Duplicates"
    @statuses = ["HQ POTENTIAL DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end


  def can_confirm
    @title = "Duplicates"
    @statuses = ["HQ DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def confirmed
    @title = "Confirmed duplicates"
    @statuses = ["HQ CONFIRMED DUPLICATE"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end


  def rejected_requests
    @title = "Rejected "
    @statuses = ["HQ REJECTED AMEND","HQ REJECTED REPRINT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def amendment_requests
    @title = "Amendment request"
    @statuses = ["DC AMEND"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def reprint_requests
    @title = "Reprint request"
    @statuses = ["DC REPRINT"]
    @page = 1
    session[:return_url] = request.path

    render :template => "case/default"
  end

  def printed_amended_or_reprint
    @title = "Reprinted and amended Certificates"
    @statuses = ["DC REPRINT"]
    @amendment = "AMENDED"
    @page = 1
    session[:return_url] = request.path

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

  def more_open_cases_with_prev_status  
    cases = []
    
    (PersonRecordStatus.by_prev_status_and_status.key([params[:prev_status],params[:status]]).page(params[:page_number]).per(10) || []).each do |status|
      
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

  def more_amended_or_reprinted_cases   
    cases = []
    
    (PersonRecordStatus.by_amend_or_reprint.page(params[:page_number]).per(10) || []).each do |status|
      
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

  def special_cases
      @title = params[:registration_type].humanize
      @statuses = ["DC AMENDED"]
      @page = 1
      session[:return_url] = request.path
      render :template => "case/default"
  end
  def more_special_cases
     cases = []
    (Person.by_registration_type.key(params[:registration_type]).page(params[:page_number]).per(10) || []).each do |person|
      cases << {
        drn: person.drn,
        den: person.den,
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

    title = "#{@person.first_name} #{@person.last_name}"
    content =  format_content(@person)

    query = "INSERT INTO documents(couchdb_id,title,content,date_added,created_at,updated_at) 
              VALUES('#{@person.id}','#{title}','#{title} #{content}','#{@person.created_at}',NOW(),NOW())"

    SQLSearch.query_exec(query)

    @statuses = [PersonRecordStatus.by_person_recent_status.key(@person.id).last.status]

    @status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last
    
    @person_place_details = place_details(@person)

    if @person.status == "DC REAPPROVED"
            @next_state ={
                "Data Checking Clerk" => ["HQ COMPLETE", "HQ POTENTIAL INCOMPLETE"],
                "Data Supervisor" => ["HQ COMPLETE", "HQ INCOMPLETE"],
                "Data Manager" => ["HQ PRINT", "HQ CONFIRMED INCOMPLETE"]
            }
    else
          @next_state ={
                "Data Checking Clerk" => ["HQ COMPLETE", "HQ POTENTIAL INCOMPLETE"],
                "Data Supervisor" => ["HQ CONFLICT", "HQ INCOMPLETE"],
                "Data Manager" => ["HQ PRINT", "HQ CONFIRMED INCOMPLETE"]
            }
    end
  end


end
