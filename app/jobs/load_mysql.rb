class LoadMysql
	include SuckerPunch::Job
  	workers 1
    @load_mysql
    class << self
      attr_accessor :load_mysql
    end
  	def perform
        if  LoadMysql.load_mysql
  		    #`rake edrs:cummulative_mysql`
        else
          pust "/////////////////////////\n"
        end
  		  if Rails.env == "development"
          SuckerPunch.logger.info "Load MYSQL"
        end
        #midnight = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time
        #now = Time.now
        #diff = (midnight  - now).to_i
        diff = 600
  			LoadMysql.perform_in(diff)
  	end
end