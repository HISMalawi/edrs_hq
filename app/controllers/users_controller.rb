class UsersController < ApplicationController

  @@file_path = "#{Rails.root.to_s}/app/assets/data/MySQL_data/"

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

  def edit_account

   # @user = User.find(params[:id])

    
     
   @user = @current_user

   # @keyboards = ['abc', 'qwerty']

    @section = "Edit Account"

    @targeturl = "/update_demographics"


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
    @targeturl = "/users/my_account"
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

      user.update_attributes(:active => false, :un_or_block_reason => params[:reason])
      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Blocked user : #{params[:reason]}")
    end

    redirect_to "/view_users" and return

  end

  def unblock_user

    redirect_to "/" and return if !has_role("Activate User")

    user = User.find(params[:id]) rescue nil

    if !user.nil?

      user.update_attributes(:active => true, :un_or_block_reason => params[:reason]) 
      Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Un-blocked user: #{params[:reason]}")

    end

    redirect_to "/view_users" and return

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
                    
    if has_role("Update system") 
      @tasks << ['Build MySQL DB','Copy data to MySQL database','/build_mysql_database','MySQL_DB.png']
    end

    if has_role("Change own password") 
    end 

  end

  def update_demographics
     
    
      @user = User.find(params[:user][:id]) rescue nil
          
        
      if @user.present?
        @user.first_name = params[:user][:first_name]
        @user.last_name = params[:user][:last_name]
        @user.email = params[:user][:email]
        @user.save
        
        redirect_to "/my_account"
      else
        redirect_to "/my_account"
      end
    
       
      
  end


  

  def change_password
   
    #redirect_to "/" and return if !(User.current_user.activities_by_level(@facility_type).include?("Change own password"))

    @section = "Change Password"

    @targeturl = "/change_password"

    @user = User.current_user



  

  end

   def confirm_password
      user = User.current_user rescue User.find(params[:user_id])
      password = params[:old_password]

      if user.password_matches?(password)
          render :text => {:response => true}.to_json
      else
        render :text => {:response => false}.to_json
      end
        
  end

def update_password
     
    user = User.current_user
    user.plain_password = params[:user][:new_password]
    user.password_attempt = 0
    user.last_password_date = Time.now
    user.save
    
    flash["notice"] = "Your new password has been changed succesfully" 
    Audit.create(record_id: user.id, audit_type: "Audit", level: "User", reason: "Updated user password")
    
    redirect_to '/my_account'

  end




  def my_account
    @task = [
               ['View details','View details','/',''],
               ['Password','Password','/','']
            ]

          #  redirect_to "/" and return if !(User.current_user.activities_by_level(@facility_type).include?("Change own password"))

    @section = "My Account"

    @user = User.current_user

   # render :layout => "landing"
  end

  def show
    @section = "User Details"

    @user = User.find(params[:id])
  end

  def build_mysql_database
    start_date = "1900-01-01 00:00:00".to_time
    end_date = (Date.today - 1.day).to_date.strftime("%Y-%m-%d 23:59:59").to_time

    @couchdb_files = {
      'Person' => {count: Person.count, name: 'Person doc.', id: 'person_doc', 
        doc_primary_key: 'person_id', table_name: 'people'},

      'PersonIdentifier' => {count: PersonIdentifier.count, name: 'PersonIdentifier doc.', 
        id: 'person_identifier_doc', doc_primary_key: 'person_identifier_id', table_name: 'person_identifier'},

      'PersonRecordStatus' => {count: PersonRecordStatus.count, name: 'PersonRecordStatus doc.', 
        id: 'person_record_status_doc', doc_primary_key: 'person_record_status_id', table_name: 'person_record_status'},
      
      'District' => {count: District.count, name: 'District doc.', 
        id: 'district_doc', doc_primary_key: 'district_id', table_name: 'district'},

      'Nationality' => {count: Nationality.count, name: 'Nationality doc.', 
        id: 'nationality_doc', doc_primary_key: 'nationality_id', table_name: 'nationality'},

      'Village' => {count: Village.count, name: 'Village doc.', 
        id: 'village_doc', doc_primary_key: 'village_id', table_name: 'village'},

      'TraditionalAuthority' => {count: TraditionalAuthority.count, name: 'TraditionalAuthority doc.', 
        id: 'traditional_authority_doc', doc_primary_key: 'traditional_authority_id', table_name: 'traditional_authority'},

      'User' => {count: User.count, name: 'User doc.', 
        id: 'user_doc', doc_primary_key: 'user_id', table_name: 'user'},

      'Role' => {count: Role.count, name: 'Role doc.', 
        id: 'role_doc', doc_primary_key: 'role_id', table_name: 'role'},

      'Country' => {count: Country.count, name: 'Country doc.', 
        id: 'country_doc', doc_primary_key: 'country_id', table_name: 'country'}

    }

    (@couchdb_files || []).each do |doc, data|
      create_file(data[:doc_primary_key], doc, data[:table_name])
    end

  end

  def create_mysql_database
    start_date = "1900-01-01 00:00:00".to_time
    end_date = (Date.today - 1.day).to_date.strftime("%Y-%m-%d 23:59:59").to_time

    data = [] ; sql_insert_field_plus_data = {}
    set_model = eval(params[:model_name])
    table_name = params[:table_name]
    records_per_page = params[:records_per_page].to_i
    page_number = params[:page_number].to_i
    table_primary_key = params[:table_primary_key]

    begin
      count = set_model.by_updated_at.startkey(start_date).endkey(end_date).page(page_number).per(records_per_page).each.count
    rescue
      count = set_model.all.page(page_number).per(records_per_page).each.count
    end

    if count > 0
      begin
        count_couchdb = set_model.by_updated_at.startkey(start_date).endkey(end_date).page(page_number).per(records_per_page).each
      rescue
        count_couchdb = set_model.all.page(page_number).per(records_per_page).each
      end

      sql_statement =<<EOF

EOF

      sql_statement += "INSERT INTO #{table_name} (#{table_primary_key}, "
    else
      render text: {people_count: count }.to_json  and return
    end

    (count_couchdb || []).each do |person|
      sql_insert_field_plus_data[person.id] = [] if sql_insert_field_plus_data[person.id].blank?
      (person.properties || []).each do |property|
        sql_insert_field_plus_data[person.id] << {
          name: "#{property.name}" , data: person.send(property.name),
          type: property.type.to_s
        }    
      end
    end 

    (sql_insert_field_plus_data || []).each do |id, statements|
      (statements || []).each do |statement|
        sql_statement += "#{statement[:name]}, "
      end
      break
    end
    sql_statement = ("#{sql_statement[0..-3]}) VALUES ")

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts sql_statement
    end



    sql_statement = ''
    (sql_insert_field_plus_data || []).each do |id, statements|
      sql_statement += "('#{id}', "

      (statements || []).each do |statement|
        if statement[:data].blank?
          if statement[:type] == 'TrueClass'
            sql_statement += "0, "
          else 
            sql_statement += "NULL, "
          end
        elsif statement[:type] == 'Integer' || statement[:type] == 'TrueClass'
          sql_statement += "#{statement[:data]},"
        elsif statement[:type] == 'Date'
          sql_statement += '"' + "#{statement[:data].to_date.strftime('%Y-%m-%d')}" + '",'
        elsif statement[:type] == 'Time'
          sql_statement += '"' + "#{statement[:data].to_time.strftime('%Y-%m-%d %H:%M:%S')}" + '",'
        else
          if statement[:data].to_s.match(/"/)
            sql_statement += "'" + "#{statement[:data]}" + "',"
          else
            sql_statement += '"' + "#{statement[:data]}" + '",'
          end
        end
      end
      sql_statement = sql_statement[0..-2] + '),'
    end
    sql_statement = sql_statement[0..-2] + ";"

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts sql_statement
    end

    render text: {people_count: count }.to_json  and return
  end

  def database_load
    @documents = {}
    (params[:documents] || {}).each do |doc, count|
      sql_file_name = "#{doc}.sql"
      @documents[sql_file_name] = count.to_i
    end

    #raise @documents.inspect
  end

  def database_load_progress
    db_result = `nice mysql -u#{mysql_connection['username']} #{mysql_connection['database']} -p#{mysql_connection['password']} -e "select count(*) as c from #{params[:table_name]};"`
    dbcount = db_result.split("\n")[1].to_i rescue 0
    render text: { count: dbcount }.to_json and return
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

  def create_file(doc_primary_key, doc, table_name)
    #Create insert statments for all documets
    #Ducument path: app/assets/data/MySQL_data/
    
    if doc_primary_key.blank?
      doc_primary_key = 'id'
      person_table = <<EOF
        DROP TABLE IF EXISTS `#{table_name}`;
        CREATE TABLE `#{table_name}` (
        `#{doc_primary_key}` INT(11)  NOT NULL AUTO_INCREMENT,
EOF
    
    else
      person_table = <<EOF
        DROP TABLE IF EXISTS `#{table_name}`;
        CREATE TABLE `#{table_name}` (
        `#{doc_primary_key}` VARCHAR(225) NOT NULL,
EOF
    
    end

    (eval(doc).properties || []).each do |property|
      field_name = property.name
      case property.type.to_s
        when 'String'
          field_type = "VARCHAR(255) DEFAULT NULL"
        when 'Date'
          field_type = "date DEFAULT NULL"
        when 'Integer'
          field_type = "INT(11) DEFAULT NULL"
        when 'Time'
          field_type = "datetime DEFAULT NULL"
        when 'TrueClass'
          field_type = "tinyint(1) NOT NULL  DEFAULT '0'"
        else
          field_type = "TEXT DEFAULT NULL" 
      end
      person_table += <<EOF
      `#{field_name}` #{field_type},
EOF

    end

    person_table += <<EOF
      PRIMARY KEY (`#{doc_primary_key}`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
EOF

    if !File.exists?(@@file_path + "#{table_name}.sql")
      file = File.new(@@file_path + "#{table_name}.sql", 'w')
    end

    #deleting all file contents
    File.open(@@file_path + "#{table_name}.sql", 'w') do |f|
      f.truncate(0)
    end

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts person_table
    end

    return true
  end

end
