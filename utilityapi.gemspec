# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'utilityapi/version'

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform.local
  spec.name          = 'utilityapi'
  spec.version       = UtilityApi::VERSION
  spec.author        = 'AUTHOR'
  spec.email         = 'EMAIL'
  spec.homepage      = 'https://github.com/utilityapi/ruby-sdk'

  spec.summary       = 'Ruby SDK for the Utility API websity API: http://utilityapi.com/api.'
  spec.description   = <<-DESCRIPTION
  UtilityAPI is an enterprise software company that delivers simple access to
  energy usage data. We aim to solve one of the biggest soft cost problems in
  the industry. We are currently in the SfunCube Solar Accelerator Program, as
  well as the Department of Energy's SunShot Catalyst Program.

  This gem is a ruby SDK for the UtilityAPI web API. Currently it provides
  access to most of the web interface features, including all sorts of
  operations with accounts and services. The SDK methods can be called either
  synchronously or asynchronously.
  DESCRIPTION
  spec.license       = 'LICENSE'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.9'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.9'

  spec.add_development_dependency 'json', '~> 1.8'
  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'factory_girl', '~> 4.5'
  spec.add_development_dependency 'yard-tomdoc', '~> 0.7'
end
