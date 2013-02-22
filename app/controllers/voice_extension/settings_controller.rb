require_dependency "voice_extension/application_controller"

module VoiceExtension
  class SettingsController < ApplicationController
    before_filter :authenticate_admin!
    
    def index
      @twilio_phone_number = AP::VoiceExtension::Voice::Config.instance.configuration[:twilio_phone_number] || ""
      @consume_url = AP::VoiceExtension::Voice::Config.instance.configuration[:consume_url] || ""
    end
    
    def update
      twilio_phone_number = params[:twilio_phone_number]
      consume_url = params[:consume_url]
      
      AP::VoiceExtension::Voice::Config.instance.configuration.merge!(twilio_phone_number: twilio_phone_number, consume_url: consume_url)
      
      # Try to set the consume url for the phone number
      begin 
        twilio_wrapper = VoiceExtension::TwilioVoiceWrapper::Voice.new
        twilio_wrapper.update_voice_url(twilio_phone_number, consume_url)
      rescue
        error = "Unable to setup the twilio phone number/url: #{$!.message}"
        Rails.logger.error(error)
        Rails.logger.error $!.backtrace.join("\n")
        flash[:error] = error
      end
      
      redirect_to settings_path
    end
    
  end
end
