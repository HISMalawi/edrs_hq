require 'couchrest_model'

class User < CouchRest::Model::Base

  def username
    self['username']
  end
  property :username , String
  property :first_name, String
  property :last_name, String
  property :password_hash, String
  property :last_password_date, Time, :default => Time.now
  property :password_attempt, Integer, :default => 0
  property :login_attempt, Integer, :default => 0
  property :email, String
  property :active, TrueClass, :default => true
  property :notify, TrueClass, :default => false
  property :role, String
  property :site_code, String
  property :creator, String
  property :plain_password, String
  property :un_or_block_reason, String
  property :signature, String
  property :_rev, String


  timestamps!

  cattr_accessor :current_user

  def has_role?(role_name)
    self.current_user.role == role_name ? true : false
  end

  def activities_by_level(level)
    Role.by_level_and_role.key([level, self.role]).last.activities  rescue []
  end

  design do
    view :by_active

    # active views
    view :active_users,
         :map => "function(doc){
            if (doc['type'] == 'User' && doc['active'] == true){
              emit(doc._id, {username: doc.username ,first_name: doc.first_name,
              last_name: doc.last_name, email: doc.email,role: doc.role,
              creator: doc.creator, notify: doc.notify, updated_at: doc.updated_at});
            }
          }"

  end

  design do
    view :by_username,
         :map => "function(doc) {
                  if ((doc['type'] == 'User')) {
                    emit(doc['username'], 1);
                  }
                }"
  end

  before_save do |pass|
    self.password_hash = BCrypt::Password.create(self.plain_password) if not self.plain_password.blank?

    self.plain_password = nil

    self.creator = 'admin' if self.creator.blank?
  end

  def password_matches?(plain_password)
    not plain_password.nil? and self.password == plain_password
  end

  def password
    @password ||= BCrypt::Password.new(password_hash)
  rescue BCrypt::Errors::InvalidHash
    Rails.logger.error "The password_hash attribute of User[#{self.username}] does not contain a valid BCrypt Hash."
    return nil
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end

  def self.create(params)
    user = User.new()
    user.username = (params[:username] rescue nil || params[:user]['username'] rescue nil)
    user.plain_password = params[:plain_password] rescue nil || params[:user]['password'] rescue nil
    user.plain_password = params[:user]['password'] if params[:plain_password].blank?
    user.first_name = (params[:first_name] rescue nil || params[:user]['first_name'] rescue nil)
    user.last_name = (params[:last_name] rescue nil || params[:user]['last_name'] rescue nil)
    user.role = (params[:role] rescue nil || params[:user]['role'] rescue nil)
    user.site_code = "HQ"
    user.email = (params[:email] rescue nil || params[:user]['email'] rescue nil)
    user.save
    return user
  end

  def self.edit(params)
    if params[:edit_action] == 'password_only'
      cur_user = User.current
      cur_user.plain_password = params[:user]['password']
      cur_user.save
    elsif params[:edit_action] == 'edit'
      cur_user = Utils::UserUtil.get_active_user(params[:username])
      cur_user.first_name = params[:user]['first_name']
      cur_user.last_name = params[:user]['last_name']
      cur_user.role = params[:user]['role']
      cur_user.email = params[:user]['email']
      cur_user.save
    end

    true
  end

  def self.get_active_user(username)

    users = User.by_username.key(username)
    users.each{|u|
      return User.find(username) if u.active == true
    }
  end

  def confirm_password
    password_hash
  end

end
