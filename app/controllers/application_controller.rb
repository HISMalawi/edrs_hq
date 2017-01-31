class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery	
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_user, :except => ['login', 'logout']

  def has_role(role)
    current_user.activities_by_level("HQ").include?(role.strip)
  end

  def place_details(person)

    places = {}

    places['home_country'] = Nationality.find(person.nationality_id).nationality rescue ""

    places['place_of_death_district'] = District.find(person.place_of_death_district_id).name rescue ""

    places['hospital_of_death'] = HealthFacility.find(person.hospital_of_death_id).name rescue ""

    places['place_of_death_ta'] = TraditionalAuthority.find(person.place_of_death_ta_id).name rescue ""

    places['place_of_death_village'] = Village.find(person.place_of_death_village_id).name rescue ""

    places['current_district'] = District.find(person.current_district_id).name rescue ""

    places['current_ta'] = TraditionalAuthority.find(person.current_ta_id).name rescue ""

    places['current_village'] = Village.find(person.current_village_id).name rescue ""

    places['home_district'] = District.find(person.home_district_id).name rescue ""

    places['home_ta'] = TraditionalAuthority.find(person.home_ta_id).name rescue ""

    places['home_village'] = Village.find(person.home_village_id).name rescue ""

    places['informant_current_district'] = District.find(person.informant_current_district_id).name rescue ""

    places['informant_current_ta'] = TraditionalAuthority.find(person.informant_current_ta_id).name rescue ""

    places['informant_current_village'] = Village.find(person.informant_current_village_id).name rescue ""

    return places

  end

  protected
  def check_user

    if !session[:user_id].blank?
      @current_user = current_user
      User.current_user = @current_user
      if @current_user.blank?
        reset_session
        redirect_to "/login"
      end
    else
      reset_session
      redirect_to "/login"
    end
  end

  def current_user
    User.find(session[:user_id])
  end
end
