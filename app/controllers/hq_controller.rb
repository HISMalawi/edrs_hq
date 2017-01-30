class HqController < ApplicationController
  def dashboard

    @icoFolder = nil

    @section = "Home"

    @targeturl = "/"

    @targettext = "Logout"

    @user = User.find_by_username(session[:current_user_id])

    @districts = {}

    District.all.each do |district|

      @districts[district.id] = district.name

    end
  end

  def search

  end
  
  def print_preview
    @section = "Print Preview"
    @targeturl = "/hq/print_certificates" 
    @child = Person.find(params[:id])
    @available_printers = CONFIG["printer_name"].split('|')
    render :layout => "application"
  end
  
  def death_certificate_preview
   
    @person = Person.find(params[:id])
    
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png") rescue nil
    
    if @barcode.nil?
      p = Process.fork{`bin/generate_barcode #{@person.npid} #{@person.id} #{CONFIG['barcodes_path']}`}
      Process.detach(p)
    end
    
    sleep(0.5)
    
    @barcode = File.read("#{CONFIG['barcodes_path']}#{@person.id}.png")
    
    render :layout => false, :template => 'hq/death_certificate'
    
  end
  
  def death_certificate
  
  end
  
  def death_certificate_print
    @person = Person.find(params[:id])
    
    if CONFIG['pre_printed_paper'] == true
       render :layout => false, :template => 'hq/death_certificate_print'
    else
       render :layout => false 
    end
  
  end
  
  def do_print_these
  
  end
  
  def print_certificates
  
  end
  
end
