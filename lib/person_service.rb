require "rails"
class PersonService
	def self.qr_code_data(id, person= nil)
	    person = Record.find(id) if person.blank?
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
	def self.verify_record(params)
		valid = true
		person = RecordIdentifier.where(identifier: params[:den]).last.person rescue nil
		if person.blank?
			valid = false
			return {message: "Record Invalid",data: nil}
		end
		
		if params[:name].strip != person.person_name
			valid = false
			return {message: "Record Invalid",data: nil}
		end
		if params[:birthdate].to_date.strftime("%Y-%m-%d") != person.birthdate.to_date.strftime("%Y-%m-%d")
			valid = false
			return {message: "Record Invalid",data: nil}
		end

		if params[:date_of_death].to_date.strftime("%Y-%m-%d") != person.date_of_death.to_date.strftime("%Y-%m-%d")
			valid = false
			return {message: "Record Invalid",data: nil}
		end

		if params[:nationality] != person.nationality
			valid = false
			return {message: "Record Invalid",data: nil}
		end

		if params[:mother_name].strip != person.mothers_name
			valid = false
			return {message: "Record Invalid",data: nil}
		end

		if params[:father_name].strip != person.fathers_name
			valid = false
			return {message: "Record Invalid",data: nil}
		end

		if params[:place_of_death].split(",").collect{|d| d.strip} != person.printable_place_of_death.split(",").collect{|d| d.strip}
			valid = false
			return {message: "Record Invalid",data: nil}
		end

		return {message: "Record valid",data: params}
	end
end