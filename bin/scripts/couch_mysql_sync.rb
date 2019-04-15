
changes "http://admin:password@localhost:5984/edrs_local" do

  # Which database should we connect to?
  #database "adapter://user:pass@host:port/test_database"
  database "mysql2://root:Mnzysk123@localhost:3306/edrs"

  document 'type' => 'User' do
    table :user
  end

end