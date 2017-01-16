class CaseController < ApplicationController
  def open
    #@cases = Person.all.page(1).per(10).each
    @page = 1
  end

  def more_open_cases

    cases = []
    
    (PersonRecordStatus.by_record_status.key("DC APPROVED").page(params[:page_number]).per(10) || []).each do |status|
      person = status.person
      cases << {
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

    @skip = [
          "birthdate_estimated", "updated_by", "voided_by", "voided_date", "voided", "approved_by", "approved_at",
          "mother_birthdate_estimated", "father_birthdate_estimated", "created_by", "changed_by", "_deleted", "_rev",
          "updated_at", "created_at", "onset_death_death_interval2", "onset_death_death_interval3", "onset_death_death_interval4",
          "other_manner_of_death", "status_changed_by"
        ]

        @person["cause_of_death"] = @person["cause_of_death1"] || @person["cause_of_death2"] || @person["cause_of_death3"] || @person["cause_of_death4"]

    @map = {
        "npid" => "National Patient ID"
    }

  end

end
