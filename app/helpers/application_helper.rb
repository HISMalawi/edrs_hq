module ApplicationHelper
  def has_role(role)
    User.find(session[:user_id]).activities_by_level("HQ").include?(role.strip)
  end
end

