class MenuOption < ActiveRecord::Base
  def self.build_menu_option(objects)
    #menu_options
    options = {}
    options["#0"] = ["menu",""]
    
    objects.each_with_index do |option, index|
      i = index+1
      options["#" + i.to_s] = "Press, #{i}, for, #{option.underscore.humanize}"
    end
    options    
  end
end
