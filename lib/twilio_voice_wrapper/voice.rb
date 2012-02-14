module TwilioVoiceWrapper

  class << self
    def sign_secret(shared_secret_key, application_id, timestamp)
      anypresence_auth = Digest::SHA1.hexdigest("#{shared_secret_key}-#{application_id}-#{timestamp}")
      {:anypresence_auth => anypresence_auth, :application_id => application_id, :timestamp => timestamp.to_s}
    end
  end
  class Voice
  end
end