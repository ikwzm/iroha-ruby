# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iroha/version'

Gem::Specification.new do |spec|
  spec.name          = "iroha-ruby"
  spec.version       = Iroha::VERSION
  spec.authors       = ["ikwzm"]
  spec.email         = ["ichiro_k@ca2.so-net.ne.jp"]

  spec.summary       = %q{Ruby library for Iroha(Intermediate Representation Of Hardware Abstraction).}
  spec.description   = %q{Ruby library for Iroha(Intermediate Representation Of Hardware Abstraction).}
  spec.homepage      = "https://github.com/ikwzm/iroha-ruby"
  
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.add_runtime_dependency     "treetop", "~> 1.6", ">= 1.6.8"
  
end
