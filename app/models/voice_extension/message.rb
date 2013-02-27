module VoiceExtension
  class Message
    include Mongoid::Document
    include Mongoid::Timestamps
  
    # Strips the phone number prefix such as +1 from +16172345678.
    # Twilio does not currently support toll-free number texting; and texting internationally is in beta.
    def self.strip_phone_number_prefix(phone_number)
      num = phone_number.strip
      if num.size >= 10
        num[-10..-1]
      else
        num
      end
    end
  end
end