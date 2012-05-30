VoiceExtension::Engine.routes.draw do
  match 'consume' => 'voice#consume'
end
