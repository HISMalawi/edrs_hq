class ApiController < ApplicationController
    def verify_certificate
        #raise RecordIdentifier.where(identifier: params[:den]).last.inspect
        render :text => PersonService.verify_record(params).to_json and return
    end

    def dc_sync
        model_map ={
                    "UserModel" =>"user_id",
                    "Record" => "person_id",
                    "RecordIdentifier" => "person_identifier_id",
                    "RecordStatus" => "person_record_status_id",
                    "VillageRecord"=> "village_id",
                    "TA" =>"traditional_authority_id",
                    "DistrictRecord" =>" district_id",
                    "CountryRecord" => "country_id",
                    "NationalityRecord"=>"nationality_id",
                    "BarcodeRecord" => "barcode_id",
                    "PersonICDCode" =>"person_icd_code_id",
                    "OtherSignificantCause" => "other_significant_cause_id"
        }
        data = params[:data]
        record = eval(data["type"]).where("#{model_map[data["type"]]}='#{data[model_map[data["type"]]]}'").first rescue nil

        record = eval(data["type"]).new if record.blank?
        
        data.keys.each do |key|
            next if key =="type"
            record[key] = data[key]
        end
        
        if record.save
            render :text => {:data =>data, :message => "Success"}.to_json and return
        else
            render :text => {:data =>data, :message => "Fail to Save"}.to_json and return
        end
    end

    def hq_sync
        hq_changes = PullSyncTracker.where(sync_status:false, district_code: params[:district_code]).order(:created_at).limit(200)
        render :text => hq_changes.as_json and return 
    end
    def get_remote_record
        model_map ={
            "UserModel" =>"user_id",
            "Record" => "person_id",
            "RecordIdentifier" => "person_identifier_id",
            "RecordStatus" => "person_record_status_id",
            "VillageRecord"=> "village_id",
            "TA" =>"traditional_authority_id",
            "DistrictRecord" =>" district_id",
            "CountryRecord" => "country_id",
            "NationalityRecord"=>"nationality_id",
            "BarcodeRecord" => "barcode_id",
            "PersonICDCode" =>"person_icd_code_id",
            "OtherSignificantCauseRecord" => "other_significant_cause_id"
        }

        type = params[:data][:type]
        record = eval(type).find(model_map[type]) rescue {}
        render :text=> record.to_json and return
    end
end