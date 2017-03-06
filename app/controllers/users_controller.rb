class UsersController < ApplicationController

	def login 
		reset_session

    if request.post?
      user = User.by_username.key(params["users"]["username"]).last

      if user and user.password_matches?(params["users"]["password"])
        session[:user_id] = user.id
        User.current_user = user
        redirect_to "/" and return
      else
        flash[:error] = "Incorrect login details!!"
        redirect_to "/login" and return
      end
    end

    render :layout => false
  end

  def new

    redirect_to "/" and return if !has_role("Create User")
    if params[:id].present?
      @user = User.find(params[:id])
    else
      @user = User.new
    end

    @section = "Create User"

    @targeturl = "/view_users"
  end

  def create

    redirect_to "/" and return if !has_role("Create User")

    uploaded_io = params[:user][:signature]
    if uploaded_io.present?
      File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end

      params[:user].merge!(:signature => uploaded_io.original_filename)
    end

    filtered = {}

    filtered = user_params.dup

    filtered.delete("_rev")
    @user = User.by_username.key(filtered[:username]).first

    if @user.blank?
      @user = User.new(filtered)
    else
      flash[:notice] = "User with that name already exists"
      redirect_to "/users/new", id: @user.id and return
    end

    respond_to do |format|

      if @user.save
        format.html { redirect_to '/view_users', notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit

    redirect_to "/" and return if !has_role("Update User")
    @section = "Edit User"
    @targeturl = "/view_users"

    if request.patch?
      @user = User.by_username.key(params[:id]).last rescue nil
      if !@user.blank? && params[:user][:password].present? && params[:user][:password].length > 1

        @user.update_attributes(:plain_password => params[:user][:password], :first_name => params[:user][:first_name],
                                :last_name => params[:user][:last_name],
                                :role =>  params[:user][:role],
                                :password_attempt => 0, :last_password_date => Time.now)
        Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Updated user password")
        redirect_to "/search_user?title=Search+for+user+to+edit&cat=edit"
      end
    else
      @user = User.by_username.key(params[:id]).last
    end
  end

  def search

    redirect_to "/" and return if !has_role("View Users")

    @section = "Search for User"
    @targeturl = "/users"
    @user = @current_user if @user.blank?
  end

  def search_by_username

    redirect_to "/" and return if !has_role("View Users")

    name = params[:id].strip rescue ""

    results = []

    if name.length > 1

      users = User.by_username.key(name).limit(10).each

    else

      users = User.by_username.limit(10).each

    end

    users.each do |user|

      next if user.username.strip.downcase == User.current_user.username.strip.downcase

      record = {
          "username" => "#{user.username}",
          "fname" => "#{user.first_name}",
          "lname" => "#{user.last_name}",
          "role" => "#{user.role}",
          "active" => (user.active rescue false)
      }

      results << record

    end

    render :text => results.to_json

  end

  def destroy

    redirect_to "/" and return if !has_role("Deactivate User")

    @user.destroy if has_role("Deactivate User")
    Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Destroyed user record")
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def block

    redirect_to "/" and return if !has_role("Deactivate User")

    @users = User.all.each

    @section = "Block User"

    @targeturl = "/users"

    render :layout => "facility"

  end

  def unblock

    redirect_to "/" and return if !has_role("Activate User")

    @users = User.all.each

    @section = "Unblock User"

    @targeturl = "/users"

    render :layout => "facility"

  end

  def block_user

    redirect_to "/" and return if !has_role("Deactivate User")

    user = User.find(params[:id]) rescue nil

    if !user.nil?

      user.update_attributes(:active => false, :un_or_block_reason => params[:reason]) if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Blocked user")
    end

    redirect_to "/view_users" and return

  end

  def unblock_user

    redirect_to "/" and return if !has_role("Activate User")

    user = User.find(params[:id]) rescue nil

    if !user.nil?

      user.update_attributes(:active => true, :un_or_block_reason => params[:reason]) if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)

      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Un-blocked user")

    end

    redirect_to "/view_users?title=View+Users" and return

  end

  def view
    redirect_to "/" and return if !has_role("View Users")

    @users = User.all.each

    @section = "View Users"

    @targeturl = "/logout"

    @user = User.current_user


  end

  def query

    redirect_to "/" and return if !has_role("View Users")

    results = []

    users = User.all.page((params[:page].to_i rescue 1)).per((params[:size].to_i rescue 20)).each

    users.each do |user|

      record = {
          "username" => "#{user.username}",
          "name" => "#{user.first_name} #{user.last_name}",
          "roles" => "#{user.role}",
          "active" => (user.active rescue false)
      }

      results << record

    end

    render :text => results.to_json

  end

  def manage_users
    @tasks = []
    if has_role("Manage Sites")
    end

    if has_role("Create User") 
      @tasks << ['Add user','Create new user','/users/new','add_person.png']
    end

    if has_role("View user log")
      @tasks << ['View users','View existing users','/view_users','config-users.png']
      #@tasks << ['Edit users','Edit existing users','/search_user?title=Search+for+user+to+edit&cat=edit','config-users.png']
    end

    if has_role("Deactivate User") 
      @tasks <<['Block users','Block existing active users','/search_user?title=Search+for+user+to+block&cat=block','block.png']
    end

    if has_role( "Activate User")
    end

    if has_role("View user log") 
    end 
  end

  def settings
    @tasks = []

    if has_role("Create User") 
      @tasks << ['Paper size','Edit certificate paper size','/paper_size','papersize.png']
      @tasks << ['Signature','Add signatures','/signature','signatures.jpeg']
    end
                    
    if has_role("Change own password") 
    end 

  end

  def my_account
    @task = [
               ['View details','View details','/',''],
               ['Password','Password','/','']
            ]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user

    @user = User.find(params[:id])

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :active, :created_at, :creator, :email, :first_name, :last_name, :notify, :plain_password, :role, :signature,:updated_at, :_rev)
  end
end
