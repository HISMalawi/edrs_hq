namespace :edrs do

  desc "Creating default user"
  task setup: :environment do
    require Rails.root.join('db','seeds.rb')
  end
  
  desc "Dropping live database"
  task drop: :environment do
     require Rails.root.join('bin','drop.rb')
  end

  desc "Updating Sync Status"
  task update_sync_status: :environment do
  	require Rails.root.join('bin','./scripts/update_sync_status.rb')
  end
  desc "Build MYSQL"
  task build_mysql: :environment do
    require Rails.root.join('bin','./scripts/build_mysql.rb')
  end

  desc "Cummulative MYSQL"
  task cummulative_mysql: :environment do
    require Rails.root.join('bin','./scripts/build_mysql_cummulative.rb')
  end

  desc "Generate sample"
  task sample: :environment do
    require Rails.root.join('bin','./scripts/sample.rb')
  end

  desc "Generate stats"
  task stats: :environment do
    require Rails.root.join('bin','./scripts/stats.rb')
  end
end
