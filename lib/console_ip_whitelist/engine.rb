module ConsoleIpWhitelist
  class Engine < ::Rails::Engine
    isolate_namespace ConsoleIpWhitelist

    initializer "console_ip_whitelist.configure_rails_initialization" do |app|
      if enable?
        insert_middleware
      end
    end

    config.after_initialize do
      path = Rails.root.join('whitelist.yml')
      default_whitelist_path = Rails.root.join("default_whitelist.yml")
      whitelisted_ips = []

      if File.exist?(path)
        whitelisted_ips = YAML.load_file(path)
      end

      if File.exist?(default_whitelist_path)
        whitelisted_ips = whitelisted_ips.concat(YAML.load_file(default_whitelist_path))
      end

      whitelisted_ips.each do |ip|
        BetterErrors::Middleware.allow_ip!(ip)
      end
    end

    def insert_middleware
      if defined? BetterErrors::Middleware
        app.middleware.insert_after BetterErrors::Middleware, ConsoleIpWhitelist::Middleware
      else
        app.middleware.use ConsoleIpWhitelist::Middleware
      end
    end

    def enable?
      !Rails.env.production? and app.config.consider_all_requests_local
    end

    def app
      Rails.application
    end

  end
end
