module VoiceExtension
  class VoiceController < ApplicationController
    # This controller interfaces with Twilio

    before_filter :build_twilio_wrapper, :only => [:settings, :make_call, :generate_consume_phone_number]
    
    def voice; end
  
    # Voices object instance to the user via Twilio.
    def menu
      account = Account.where(:consume_phone_number => params[:To]).first
      menu_option = account.menu_options.where(:name => params[:object_name].downcase.strip).first
      response = menu_option.build_voice_response(params[:Digits])
    
      render :text => response.text
    end
  
    # Consumes voice call from Twilio and presents it with a menu.
    def consume
      consume_phone_number = params[:To]
      
      Rails.logger.info "Current page is: #{params[:current_page]}"
      
      # Check what was pressed.
      if params[:Digits].blank?
        # Show main menu
        response = VoiceExtension::MenuOption::build_menu_option
      else
        begin
          page = VoiceExtension::Page.where(name: params[:current_page]).first
          response = VoiceExtension::MenuOption::build_menu_option(params[:Digits].to_s, page)
        rescue
          Rails.logger.error "Unable to generate menu: #{$!.message}"
          Rails.logger.error $!.backtrace.join("\n")
          response = Twilio::TwiML::Response.new do |r|
            r.Say VoiceExtension::MenuOption::GENERIC_ERROR_MESSAGE_TO_VOICE, :voice => 'woman'
          end
        end
      end
    
      begin
        render :text => response.text
      rescue
        Rails.logger.error $!.message
      end
    end

  
  protected

    # Builds the +Consumer+ which accesses Twilio.
    def build_twilio_wrapper
      @twilio_wrapper = ::VoiceExtension::TwilioVoiceWrapper::Voice.new(current_account.id)
    end
  end
end