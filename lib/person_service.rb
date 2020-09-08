require "rails"
class PersonService
	def self.qr_code_data(id)
	    person = Person.find(id)
		date_registered = person.created_at

		registered_state = RecordStatus.where(person_record_id: person.id, status: 'HQ ACTIVE').order(:created_at).first
		if registered_state.present?
			date_registered = registered_state.created_at
		end

	    str = "05~#{person.npid}-#{person.den}-#{person.drn}"
	    str += "~#{person.person_name}~#{person.birthdate.to_date.strftime("%d-%b-%Y")}~#{person.gender.first}"
	    str += "~#{person.nationality}"    
	    str += "~#{person.date_of_death.to_date.strftime("%d-%b-%Y")}"
	    str += "~#{person.printable_place_of_death}"
	    str += ("~#{person.mothers_name}" rescue '~')
	    str += ("~#{person.fathers_name}" rescue '~')
	    str += ("~#{date_registered.to_date.strftime("%d-%b-%Y")}" rescue nil)

	    str
  	end
end