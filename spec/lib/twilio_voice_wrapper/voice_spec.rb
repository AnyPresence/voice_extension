require 'spec_helper'

describe VoiceExtension::TwilioVoiceWrapper::Voice do
  def setup_twilio
     twilio_client = double('twilio_client')
     Twilio::REST::Client.should_receive(:new).with(any_args()).and_return(twilio_client)
     @twilio_account = double('twilio_account')
     twilio_client.should_receive(:account).and_return(@twilio_account) 
  end
  
  describe "update voice url" do
    it "should update" do
      setup_twilio
      voice = VoiceExtension::TwilioVoiceWrapper::Voice.new
      incoming_phone_number = double('phone numbers')
      incoming_phone_number.stub(:phone_number).and_return("11112223333")
      incoming_phone_number.stub(:sid).and_return("123")
      @twilio_account.stub_chain(:incoming_phone_numbers, :list).and_return([incoming_phone_number])
      @twilio_account.stub_chain(:incoming_phone_numbers, :get, :update)
      voice.update_voice_url("11112223333", "http://localhost")
    end
  end
end