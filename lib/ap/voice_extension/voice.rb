require 'singleton'

module AP
  module VoiceExtension
    module Voice
      def self.config_account(config={})
        twilio_account_sid = ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID']
        twilio_account_sid = ENV['AP_SMS_NOTIFIER_TWILIO_ACCOUNT_SID']
      
        Config.instance.configuration ||= HashWithIndifferentAccess.new
        Config.instance.configuration = Config.instance.configuration.merge(config)        
      end

      class Config
        include Singleton
        attr_accessor :configuration
      end
      
    end
  end
end