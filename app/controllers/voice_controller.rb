class VoiceController < ApplicationController
  
  def consume
    @voice = TwilioVoiceWrapper::Voice.new
    
  end
  
end
