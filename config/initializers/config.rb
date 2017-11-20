CONFIG = YAML.load_file(Rails.root.join('config', 'couchdb.yml'))[Rails.env]
MYSQL = YAML.load_file(File.join(Rails.root, "config", "database.yml"))[Rails.env]
def start
	query ="mysql -u #{MYSQL['username']} -p#{MYSQL['password']} -e \"CREATE DATABASE IF NOT EXISTS #{MYSQL['database']};\"" 
	`#{query}`
end
start
