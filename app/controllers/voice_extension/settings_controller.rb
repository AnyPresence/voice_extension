require_dependency "voice_extension/application_controller"

module VoiceExtension
  class SettingsController < ApplicationController
    before_filter :authenticate_admin!
    
    def index
      @consume_phone_number = AP::VoiceExtension::Voice::Config.instance.configuration[:consume_phone_number] || ""
      if AP::VoiceExtension::Voice::Config.instance.configuration[:consume_url].blank? && !@consume_phone_number.blank?
        # Retrieve voice url
        twilio_wrapper = VoiceExtension::TwilioVoiceWrapper::Voice.new
        @consume_url = twilio_wrapper.get_voice_url(@consume_phone_number)
      else
        @consume_url = AP::VoiceExtension::Voice::Config.instance.configuration[:consume_url]
      end
    end
    
    def update
      consume_phone_number = params[:consume_phone_number]
      consume_url = params[:consume_url]
      
      # Try to set the consume url for the phone number
      begin 
        twilio_wrapper = VoiceExtension::TwilioVoiceWrapper::Voice.new
        twilio_wrapper.update_voice_url(consume_phone_number, consume_url)
        AP::VoiceExtension::Voice::Config.instance.configuration.merge!(consume_phone_number: consume_phone_number, consume_url: consume_url)
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
