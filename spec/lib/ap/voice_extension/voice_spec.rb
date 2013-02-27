require 'spec_helper'
require 'ap/voice_extension/voice'

describe AP::VoiceExtension::Voice do
  describe "configure" do 
    it "should configure successfully" do
      ENV['AP_IVR_NOTIFIER_CONSUME_URL'] = "http://localhost" 
      AP::VoiceExtension::Voice.config_account
      AP::VoiceExtension::Voice::Config.instance.configuration[:consume_url].should == "http://localhost" 
    end
  end
end