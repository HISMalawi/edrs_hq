namespace :edrs do

  desc "Creating default user"
  task setup: :environment do
    require Rails.root.join('db','seeds.rb')
  end
  
  desc "Dropping live database"
  task drop: :environment do
     require Rails.root.join('bin','drop.rb')
  end
  
end
