# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fixed_width_file_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "fixed_width_file_parser"
  spec.version       = FixedWidthFileParser::VERSION
  spec.authors       = ["Jim Smith"]
  spec.email         = ["jim@jimsmithdesign.com"]

  spec.summary       = "Parse fixed width files easily and efficiently."
  spec.homepage      = "https://github.com/elevatorup/fixed_width_file_parser"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
end
