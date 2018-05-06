class GenerateStats
	include SuckerPunch::Job
  	workers 1
  
  	def perform()
      `bundle exec rake edrs:stats`
      if Rails.env == "development"
      	 GenerateStats.perform_in(10)
      else	
      	GenerateStats.perform_in(300)
      end
  		
  	end
end