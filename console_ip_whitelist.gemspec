$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "console_ip_whitelist/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "console_ip_whitelist"
  s.version     = ConsoleIpWhitelist::VERSION
  s.authors     = ["Murugan"]
  s.email       = ["murugan@firstdraft.com"]
  s.homepage    = "https://github.com/firstdraft"
  s.summary     = "ConsoleIpWhitelist."
  s.description = "ConsoleIpWhitelist."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails"

  s.executables = ['ipwhitelist']

  s.add_development_dependency(%q<better_errors>)

end
