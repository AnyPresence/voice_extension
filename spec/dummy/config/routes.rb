Rails.application.routes.draw do

  mount VoiceExtension::Engine => "/voice_extension"
end
