require 'singleton'

module AP
  module VoiceExtension
    module Voice
      def self.config_account(config={})
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