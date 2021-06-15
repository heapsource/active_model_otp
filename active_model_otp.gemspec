# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_model/otp/version'

Gem::Specification.new do |spec|
  spec.name          = "active_model_otp"
  spec.version       = ActiveModel::Otp::VERSION
  spec.authors       = ["Guillermo Iguaran", "Roberto Miranda", "Heapsource"]
  spec.email         = ["guilleiguaran@gmail.com", "rjmaltamar@gmail.com", "hello@firebase.co"]
  spec.description   = %q{Adds methods to set and authenticate against one time passwords 2FA(Two factor Authentication). Inspired in AM::SecurePassword"}
  spec.summary       = "Adds methods to set and authenticate against one time passwords."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "activemodel"
  spec.add_dependency "rotp", "~> 6.2.0"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.4.2"
  spec.add_development_dependency "appraisal"

  if RUBY_PLATFORM == "java"
    spec.add_development_dependency "activerecord-jdbcsqlite3-adapter"
  else
    spec.add_development_dependency "sqlite3", "~> 1.4"
  end
end
