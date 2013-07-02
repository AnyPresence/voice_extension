require 'singleton'

module AP
  module VoiceExtension
    module Voice
      def self.config_account(config={})
        config[:consume_url] = ENV['AP_IVR_NOTIFIER_CONSUME_URL'] unless ENV['AP_IVR_NOTIFIER_CONSUME_URL'].blank?
        
        Config.instance.configuration ||= HashWithIndifferentAccess.new
        Config.instance.configuration = Config.instance.configuration.merge(config) 
      end

      class Config
        include Singleton
        attr_accessor :latest_version, :configuration
      end
      
    end
  end
end