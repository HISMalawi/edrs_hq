class UsersController < ApplicationController

	def login 
		reset_session

    if request.post?

      user = User.by_username.key(params["users"]["username"]).last

      if user and user.password_matches?(params["users"]["password"])
        session[:user_id] = user.id
        redirect_to "/"
      else
        redirect_to "/login"
      end
    end
	end
end
