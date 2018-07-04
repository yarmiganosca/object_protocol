
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "object_protocol/version"

Gem::Specification.new do |spec|
  spec.name          = "object_protocol"
  spec.version       = ObjectProtocol::VERSION
  spec.authors       = ["Chris Hoffman"]
  spec.email         = ["yarmiganosca@gmail.com"]

  spec.summary       = "Write object protocols instead of message expectations."
  spec.description   = "Write object protocols instead of message expectations."
  spec.homepage      = "https://www.github.com/yarmiganosca/object_protocol"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "structured_changelog"

  spec.add_dependency "binding_of_caller"
end
