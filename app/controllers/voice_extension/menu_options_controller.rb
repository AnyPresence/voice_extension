require_dependency "voice_extension/application_controller"

module VoiceExtension
  class MenuOptionsController < ApplicationController
    before_filter :authenticate_admin!
    
    def index
    end
  end
end
