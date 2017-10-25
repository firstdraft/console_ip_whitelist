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
      if File.exist?(path)
        whitelisted_ips = YAML.load_file(path)
        whitelisted_ips.each do |ip|
          BetterErrors::Middleware.allow_ip!(ip)
        end
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
