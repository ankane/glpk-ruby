require_relative "lib/glpk/version"

Gem::Specification.new do |spec|
  spec.name          = "glpk"
  spec.version       = Glpk::VERSION
  spec.summary       = "Linear programming kit for Ruby"
  spec.homepage      = "https://github.com/ankane/glpk-ruby"
  spec.license       = "GPL-3.0-or-later"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.7"
end
