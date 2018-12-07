# coding: utf-8

require File.expand_path("lib/clvpn/version")

Gem::Specification.new do |spec|
  spec.name         = "clvpn"
  spec.version      = Clvpn::VERSION
  spec.authors      = ["Michael Crowther"]
  spec.email        = ["crow404@gmail.com"]
  spec.license      = "MIT"
  spec.summary      = "Openvpn configuration utility"
  spec.description  = "CLI for generating openvpn config files."
  spec.files        = `git ls-files -- lib bin README.md LICENSE`.split("\n")
  spec.executables  = ["clvpn"]
  spec.require_path = "lib"

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "erubis"
  spec.add_dependency "tty-tree"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
