class ApiController < ApplicationController
    def verify_certificate
        #raise RecordIdentifier.where(identifier: params[:den]).last.inspect
        render :text => PersonService.verify_record(params).to_json and return
    end
end