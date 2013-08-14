# -*- encoding: utf-8 -*-
# Copyright (c) GoPivotal (UK) Ltd.

Gem::Specification.new do |s|
  s.name         = "support_cf_plugin"
  s.version      = '0.0.1'
  s.platform     = Gem::Platform::RUBY
  s.summary      = "CF Support Functions"
  s.description  = "CF command line extensions to make support easier"
  s.author       = "GoPivotal"
  s.homepage      = 'https://github.com/cloudfoundry/bootstrap-cf-plugin'
  s.license       = 'Apache 2.0'
  s.email         = "support@cloudfoundry.com"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  s.files        = `git ls-files -- lib/* templates/*`.split("\n") + %w(README.md)
  s.require_path = "lib"

  s.add_dependency "cf"
  # s.add_dependency "haddock"
end