#module VoiceExtension
  class VoiceController < ApplicationController
    # We can do SSO from the hash AnyPresence sends
    # before_filter :authenticate_from_anypresence, :only => [:deprovision, :settings, :publish]
  
    # Normal Devise authentication logic
    #before_filter :authenticate_account!, :except => [:unauthorized, :provision, :consume, :menu]
    #before_filter :find_api_version, :only => [:provision, :publish]
    before_filter :build_twilio_wrapper, :only => [:settings, :make_call, :generate_consume_phone_number]
  
    def voice
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

  
  protected

    # Builds the +Consumer+ which accesses Twilio.
    def build_twilio_wrapper
      @twilio_wrapper = ::VoiceExtension::TwilioVoiceWrapper::Voice.new(current_account.id)
    end
  end
#end