class CaseController < ApplicationController
  def open
    #@cases = Person.all.page(1).per(10).each
    @page = 1
  end

  def more_open_cases

    cases = []
    
    (Person.all.page(params[:page_number]).per(10) || []).each do |person|
      cases << {
        first_name: person.first_name,
        last_name:  person.last_name,
        dob:        person.birthdate,
        gender:     person.gender
      }
    end

    render text: cases.to_json and return
  end

end
