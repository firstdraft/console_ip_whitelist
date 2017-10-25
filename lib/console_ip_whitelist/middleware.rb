module ConsoleIpWhitelist
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      @ip = request.ip
      @app.call(env)
    rescue Exception => ex
      if pass_through?
        @app.call(env)
      else
        [200, {"Content-Type" => "text/html"}, [error_message]]
      end
    end

    def pass_through?
      path = Rails.root.join('whitelist.yml')
      if File.exist?(path)
        whitelisted_ips = YAML.load_file(path)
        whitelisted_ips.include?(@ip)
      else
        true
      end
    end

    def error_message
  %Q{Uh oh! Something went wrong.

 If you are the application owner, to get a more helpful error page please run this command at a terminal prompt:

 `bin/whitelist #{@ip}`}
    end
  end
end
