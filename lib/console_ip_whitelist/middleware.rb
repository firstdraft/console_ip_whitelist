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
      default_whitelist_path = Rails.root.join("default_whitelist.yml")
      whitelisted_ips = []
      file_exist = false

      if File.exist?(path)
        file_exist = true
        whitelisted_ips = YAML.load_file(path)
      end

      if File.exist?(default_whitelist_path)
        file_exist = true
        whitelisted_ips = whitelisted_ips.concat(YAML.load_file(default_whitelist_path))
      end

      if file_exist
        whitelisted_ips.include?(@ip)
      else
        true
      end
    end

    def error_message
      <<-HTML
      <!DOCTYPE html>
<html>

<head>
  <title>Enhance your error page</title>

  <!-- Expand the number of characters we can use in the document beyond basic ASCII 🎉 -->
  <meta charset="utf-8">

  <!-- Connect Bootstrap CSS -->
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">

  <!-- Make it responsive to small screens -->
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
</head>

<body>
  <div class="container pt-4 text-center">
    <div class="row mb-3">
      <div class="col-md-8 offset-md-2">
        <div class="alert alert-danger">
          <p class="h2">
            Hey you — yes, <span style="text-transform: uppercase;">you</span> — <em>read</em> this message, don't ignore it.
          </p>
        </div>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-8 offset-md-2">
        <h1 class="display-4">Congratulations! There's an error in your code. That means you're making progress!</h1>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-8 offset-md-2">
        <p class="h3">Now it's time to debug. To get a really helpful error page, copy-paste this command at a terminal prompt:</p>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-8 offset-md-2">
        <div class="jumbotron py-2 mb-3">
          <pre style="font-size: 2.5em;"><code>bin/whitelist #{@ip}</code></pre>
        </div>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-8 offset-md-2">
        <p class="h3">and then <span style="text-transform: uppercase;">restart your server</span>. Then, refresh this page. You'll see a supercharged error page. In addition to the high-level error message at the top of the page, you'll have:</p>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-8 offset-md-2">
        <img src="https://firstdraft.github.io/console_ip_whitelist/better_errors_diagram.png" class="img-fluid">
      </div>
    </div>
  </div>
</body>

</html>
      HTML
    end
  end
end
