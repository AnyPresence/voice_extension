class MenuOptionController < ApplicationController

  def index
    @menu_options = current_account.menu_options
  end
  
  def new
    menu_options = current_account.menu_options.all
    menu_options.each do |x|
      @available_objects.delete(x.name)
    end
  end
  
end
