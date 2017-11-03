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
      <<-HTML
        <h1>Uh oh! You've got an error in your code.</h1>

        <h2>To get a more helpful error page, please run this command at a terminal prompt:</h2>

        <pre style="font-size: 4em;"><code>bin/whitelist #{@ip}</code></pre>

        <h2>and then restart your server.</h2>
      HTML
    end
  end
end
