require 'spec_helper'

describe VoiceExtension::MenuOption do
  
  describe "build voice menu" do
    it "should pluralize objects" do
      objects = ["stuff", "thing"]
      response = MenuOption::build_menu_option(objects)

      response.text.should include("Press, 1, for, Stuffs")
      response.text.should include("Press, 2, for, Things")
    end
  end
end
