require 'spec_helper'

describe VoiceExtension::MenuOption do
  
  describe "build voice menu" do
    it "should pluralize objects" do
      objects = ["stuff", "thing"]
      ENV['VOICE_CONSUME_URL'] = "http://localhost/"
      response = ::VoiceExtension::MenuOption::build_menu_option(objects)

      response.text.should include("Press, 1, for, Stuffs")
      response.text.should include("Press, 2, for, Things")
    end
  end
end
