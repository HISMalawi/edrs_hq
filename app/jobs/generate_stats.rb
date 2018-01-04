class GenerateStats
	include SuckerPunch::Job
  	workers 1
  
  	def perform()
      `rake edrs:stats`
  		GenerateStats.perform_in(600)
  	end
end