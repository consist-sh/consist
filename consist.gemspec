require_relative "lib/consist/version"

Gem::Specification.new do |spec|
  spec.name = "consist"
  spec.version = Consist::VERSION
  spec.authors = ["John McDowall"]
  spec.email = ["j@jmd.fm"]

  spec.summary = "The one person framework server scaffolder"
  spec.homepage = "https://github.com/johnmcdowall/consist"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/johnmcdowall/consist/issues",
    "changelog_uri" => "https://github.com/johnmcdowall/consist/releases",
    "source_code_uri" => "https://github.com/johnmcdowall/consist",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "net-ssh", "~> 7.0"
  spec.add_dependency "sshkit", "~> 1.21"
  spec.add_dependency "thor", "~> 1.2"
end
