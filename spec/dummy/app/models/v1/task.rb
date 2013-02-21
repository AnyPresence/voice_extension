class V1::Task
  include Mongoid::Document
  include Mongoid::Timestamps
  include AP::VoiceExtension
  
  field :"_id", as: :id, type: String
     
end
