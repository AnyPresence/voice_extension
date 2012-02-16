module TwilioVoiceWrapper

  class << self
    def sign_secret(shared_secret_key, application_id, timestamp)
      anypresence_auth = Digest::SHA1.hexdigest("#{shared_secret_key}-#{application_id}-#{timestamp}")
      {:anypresence_auth => anypresence_auth, :application_id => application_id, :timestamp => timestamp.to_s}
    end
  end
  
  class Voice
    
    def initialize(account_id)
      @account_id = account_id
    end
    
    def twilio_account
      @twilio_account ||= Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']).account 
    end
    
    # Provisions new phone number with Twilio.
    def provision_new_phone_number(phone_number, voice_consume_url)
      begin
        twilio_account.incoming_phone_numbers.create({:phone_number => phone_number, :voice_url => voice_consume_url})
      rescue => e
        Rails.logger.error "Unable to provision number: " + phone_number + " , voice_url: " + voice_consume_url
        raise e
      end
    end
    
    # Checks to see if we should provision a new phone number or use what is available.
    def provision_new_phone_number?(phone_number)
      used_numbers = Account::get_used_phone_numbers
      used_numbers << phone_number
      if find_available_purchased_phone_number(used_numbers).nil?
        true
      else
        false
      end
    end
    
    # Gets phone number to purchase by area code
    def get_phone_number_to_purchase(area_code)
      local_numbers = twilio_account.available_phone_numbers.get('US').local
      numbers = local_numbers.list(:area_code => area_code)
      numbers.first.phone_number if !numbers.nil?
    end
    
    # Updates VOICE_URL for phone number
    def update_voice_url(phone_number)
      twilio_owned_numbers = twilio_account.incoming_phone_numbers.list
      sid = ""
      twilio_owned_numbers.each do |x|
        sid = x.sid if x.phone_number.match(Message::strip_phone_number_prefix(phone_number))
      end
      
      twilio_account.incoming_phone_numbers.get(sid).update({:voice_url => ENV['VOICE_CONSUME_URL']})
    end
    
    def find_available_purchased_phone_number(used_numbers)    
      # Check to see if there are numbers that we own that are not being used by any account
      twilio_owned_numbers = twilio_account.incoming_phone_numbers.list
      first_available_owned_number = Account::phone_number_used(twilio_owned_numbers, used_numbers)
    end
    
  end
end