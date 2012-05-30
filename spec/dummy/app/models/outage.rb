class Outage
  include Mongoid::Document
  include Mongoid::Timestamps
  include AP::SmsExtension::Sms
  
  # Field definitions
  
  field :"_id", as: :id, type: String

  field :"title", type: String

  field :"num_affected", type: Integer

  field :"latitude", type: Float

  field :"longitude", type: Float
     
  
end
