class Account

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :consume_phone_number, :api_host

  NUM_ENTRIES = 2

  
  class << self
    def find_by_consume_phone_number(phone_number)
      Account.find_by_consume_phone_number(phone_number)
    end
  
    # Gets the first available phone number if any.
    # An available phone number must be a number in Twilio that we are not using and
    # it must not have an SMS_URL associated with it.
    def phone_number_used(twilio_owned_numbers, used_numbers)
      available_phone_number = nil
      twilio_owned_numbers.each do |x|
        if x.voice_url.empty? && !used_numbers.include?(x.phone_number)
          available_phone_number = x.phone_number
          break
        end
      end
      available_phone_number
    end
  
    def get_used_phone_numbers
      Account.all.map {|x| x.consume_phone_number }
    end
  
    def generate_secure_parameters
      timestamp = Time.now.to_i
      application_id = @account.application_id
      {timestamp: timestamp.to_s, application_id: application_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{application_id}-#{timestamp}") } 
    end
  end
  
  # Build an AnypresenceExtension client.
  def ap_client(*adhoc_api_version)
    version = adhoc_api_version.empty? ? 'latest' : adhoc_api_version[0]
    @ap_client ||= AnypresenceExtension::Client.new(self.api_host, self.api_token, self.application_id, version)
  end
  
  # Gets object definition metadata using API call.
  def object_definition_metadata
    response = ap_client(self.api_version).metadata.fetch

    Rails.logger.info "response: " + response.inspect
    parsed_json = []
    case response.status
    when 200
      begin
        parsed_json = ActiveSupport::JSON.decode(response.body)
      rescue MultiJson::DecodeError
        raise "Unable to decode the JSON message for url: #{url}"
      end
    else
      raise "Unable to get a response for url: #{url}"
    end
  
    parsed_json
  end
  
  # Gets object definition names for an application
  def object_definition_mappings
    parsed_json = object_definition_metadata

    object_names = []
    parsed_json.each do |object_definition|
      object_names << object_definition["name"].downcase
    end
    object_names
  end
  
  # Gets object instances.
  def object_instances(object_name, format)
    # Access the latest version.
    response = ap_client.data(object_name).fetch

    parsed_json = json_decode_response('', response)     
    
    msg_for_client = []
    count = 0
    parsed_json.each do |x|
        break if count == NUM_ENTRIES
        count += 1
        msg_for_client << MenuOption::parse_format_string(format, object_name, x).to_s
    end
    msg_for_client
  end

private
  def json_decode_response(url, response)
    parsed_json = []
    case response.status
    when 200
      begin
        parsed_json = ActiveSupport::JSON.decode(response.body)
      rescue MultiJson::DecodeError
        raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to decode the JSON message: #{url}"
      end
    when 301
      raise ConsumeSms::GeneralTextMessageNotifierException, "Unexpected redirection occurred: #{url}"
    else
      raise ConsumeSms::GeneralTextMessageNotifierException, "Unable to get a response: #{url}"
    end
    parsed_json
  end

end
