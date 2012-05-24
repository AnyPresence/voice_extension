module AP
  module VoiceExtension
    def self.config_account(config={})
      if config.empty?
        raise "Nothing to configure!"
      end
      account = nil
      if !::EmailExtension::Account.all.blank?
        account = ::EmailExtension::Account.first
        account.update_attributes(config)
      else
        account = ::EmailExtension::Account.new(config)
        account.save!
      end

      menu_options = config[:menu_options] 
      if !menu_options.nil?
        menu_options.each do |m|
          menu_option = account.menu_options.build(m)
          menu_option.save
        end
      end
    end
  end
end