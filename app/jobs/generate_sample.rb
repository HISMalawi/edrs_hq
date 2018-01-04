class GenerateSample
	include SuckerPunch::Job
  	workers 1
  	def perform
  		  `rake edrs:sample`
  		  if Rails.env == "development"
          SuckerPunch.logger.info "Sampling coder data"
        end
        midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
        now = Time.now
        diff = (midnight  - now).to_i
  			GenerateSample.perform_in(diff)
  	end
end