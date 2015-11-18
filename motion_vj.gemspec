# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motion_vj/version'

Gem::Specification.new do |spec|
  spec.name          = "motion_vj"
  spec.version       = MotionVj::VERSION
  spec.authors       = ["Roque Pinel"]
  spec.email         = ["repinel@gmail.com"]

  spec.summary       = %q{Motion videos visualizer.}
  spec.description   = %q{Motion videos visualizer.}
  spec.homepage      = "https://github.com/repinel/motion_vj"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'dotenv', "~> 2.0"
  spec.add_dependency 'dropbox-sdk', "~> 1.6"
  spec.add_dependency 'listen', "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.8"
end
