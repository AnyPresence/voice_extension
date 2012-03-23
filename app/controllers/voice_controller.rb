class VoiceController < ApplicationController
  # We can do SSO from the hash AnyPresence sends
  before_filter :authenticate_from_anypresence, :only => [:deprovision, :settings, :publish]
  
  # Normal Devise authentication logic
  before_filter :authenticate_account!, :except => [:unauthorized, :provision, :consume, :menu]
  before_filter :find_api_version, :only => [:provision, :publish]
  before_filter :build_twilio_wrapper, :only => [:settings, :make_call, :generate_consume_phone_number]
  
  # This creates an account on our side tied to the application and renders back the expected result to create a new add on instance.
  def provision
    if valid_request?
      account = Account.where(:application_id => params[:application_id]).first
      if account.nil?
        account = Account.new
        account.application_id = params[:application_id]
      end
      account.extension_id = params[:add_on_id]
      account.api_token = params[:api_token]
      account.api_version = @api_version
      account.api_host = "#{ENV['CHAMELEON_HOST']}".strip.gsub(/\/+$/, '')
      
      account.save!
        
      render :json => {
        :success => true,
        :build_objects => [
          {
            :type => 'WebService',
            :name => 'Voice Service',
            :url => voice_url,
            :method => 'POST',
            :web_service_fields_attributes => [
              { :name => "auth_token", :value => account.authentication_token }
            ]
          }
        ]
      }
    else      
      render :json => { :success => false }
    end
  end
  
  # This deprovisions the current account. We can't get here unless we're signed in, so we know it's a valid request.
  def deprovision
    current_account.destroy
    render :json => { :success => true }
  end
  
  def voice
  end
  
  # This renders our settings page and handles updates of the account.
  def settings
    if request.put?
      if params[:account][:consume_phone_number] == "N/A"
        consume_phone_number = params[:account][:consume_phone_number] = nil
      else
        consume_phone_number = params[:account][:consume_phone_number]
      end

      # Check if we should provision this phone number, or if we own it already.
      if current_account.consume_phone_number.nil? && !consume_phone_number.nil?
        # Check if we have a phone number available.
        if @twilio_wrapper.provision_new_phone_number?(consume_phone_number)
          begin
            # Let's buy this phone number.
            @twilio_wrapper.provision_new_phone_number(consume_phone_number, ENV['VOICE_CONSUME_URL'])
          rescue
            params[:account][:consume_phone_number] = nil
          end
        else
          # Use the phone number we already own but update the sms url.
          begin
            Rails.logger.info "Updating voice_url for : " + consume_phone_number
            @twilio_wrapper.update_voice_url(consume_phone_number)
          rescue
            Rails.logger.error $!
            Rails.logger.error $!.backtrace
            flash[:alert] = "Unable to update the url to consume Voice on Twilio."
          end
        end
      end

      if current_account.update_attributes params[:account]
        flash[:notice] = "Account updated."
      else
        flash[:alert] = "Account could not be updated."
      end

      redirect_to settings_path
    end

  end
  
  # This is the endpoint for when new applications are published
  def publish
    new_api_version = @api_version

    if new_api_version.nil?
       render :json => { :success => false } 
    elsif current_account.api_version.nil? || new_api_version.to_i > current_account.api_version.to_i
      Rails.logger.info "new api version found: " + @api_version
      current_account.api_version = new_api_version
      current_account.save!
      
      render :json => { :success => true, :message => "The extensions will now use the latest version."}
    else
      render :json => { :success => true }
    end
  end
  
  # Voices object instance to the user via Twilio.
  def menu
    account = Account.where(:consume_phone_number => params[:To]).first
    menu_option = account.menu_options.where(:name => params[:object_name].downcase.strip).first
    response = menu_option.build_voice_response(params[:Digits])
    
    render :text => response.text
  end
  
  # Consumes voice call from Twilio and presents it with a menu.
  def consume
    account = Account.where(:consume_phone_number => params[:To]).first
    objects = account.object_definition_mappings
    Rails.logger.info "objects: " + objects.inspect
    
    begin
      response = MenuOption::build_menu_option objects
      
      render :text => response.text
    rescue
      Rails.logger.error $!.message
      render :text => 'Error!'
    end
  end

  # Generates a phone number to consume SMS
  def generate_consume_phone_number
    if current_account.consume_phone_number.nil?
      first_available_owned_number = @twilio_wrapper.find_available_purchased_phone_number(Account::get_used_phone_numbers)
      # Try to obtain a new number from Twilio
      current_account.consume_phone_number =  first_available_owned_number.nil? ? @twilio_wrapper.get_phone_number_to_purchase(params[:area_code]) : first_available_owned_number
    end
    
    respond_to do |format|  
      format.js
    end
  end
  
protected
  # If the request is valid, we log in as the account tied to the application that was passed.
  def authenticate_from_anypresence
    if valid_request?
      account = Account.find_by_application_id params[:application_id]
      if account.nil?
        raise "Unable to find the account."
      end
      sign_in account
    elsif current_account
      true
    else
      unauthorized 
    end
  end

  # A request is valid if it is both recent and was properly signed with our shared secret.
  def valid_request?
    signed_secret = TwilioVoiceWrapper::sign_secret(ENV['SHARED_SECRET'], params[:application_id], params[:timestamp])
    recent_request? && params[:anypresence_auth] == signed_secret[:anypresence_auth]
  end

  # We define the request as recent if it originated from the AnyPresence server more than 30 seconds ago. This should be enough time
  # for both network latency and clock synchronization issues.
  def recent_request?
    begin
      Time.at(params[:timestamp].to_i) > 30.seconds.ago
    rescue
      false
    end
  end

  # Finds the API version in the header.
  def find_api_version
    if Rails.env.test?
      @api_version = request.env["X_AP_API_VERSION"]
    else
      @api_version = request.env["HTTP_X_AP_API_VERSION"]
    end
  end

  # Finds the object definition name.
  def find_object_definition_name
    if Rails.env.test?
      @object_definition_name = request.env["X_AP_OBJECT_DEFINITION_NAME"]
    else
      @object_definition_name = request.env["HTTP_X_AP_OBJECT_DEFINITION_NAME"]
    end
  end

  # Builds the +Consumer+ which accesses Twilio.
  def build_twilio_wrapper
    @twilio_wrapper = TwilioVoiceWrapper::Voice.new(current_account.id)
  end
end
