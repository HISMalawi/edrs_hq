class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery	
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_user, :except => ['login', 'logout']


	protected
  def check_user
    if !session[:user_id].blank?
      @current_user = current_user
    else
      reset_session
      redirect_to "/login"
    end
  end

  def current_user
    User.find(session[:user_id])
  end
end
