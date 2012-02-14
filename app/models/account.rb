class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # Build an AnypresenceExtension client.
  def ap_client(*api_version)
    version = api_version.nil? ? self.api_version : 'latest'
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
  
  def self.generate_secure_parameters
    timestamp = Time.now.to_i
    application_id = @account.application_id
    {timestamp: timestamp.to_s, application_id: application_id, anypresence_auth: Digest::SHA1.hexdigest("#{ENV['SHARED_SECRET']}-#{application_id}-#{timestamp}") } 
  end
end
