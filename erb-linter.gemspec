# frozen_string_literal: true

require_relative "lib/erb/linter"

Gem::Specification.new do |spec|
  spec.name          = "erb-linter"
  spec.version       = ERB::Linter::VERSION
  spec.authors       = ["Elia Schito"]
  spec.email         = ["elia@schito.me"]

  spec.summary       = "Check your ERB files for closing tags, indentation, bad attributes etc."
  spec.homepage      = "https://github.com/nebulab/erb-linter#readme"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nebulab/erb-linter"
  spec.metadata["changelog_uri"] = "https://github.com/nebulab/erb-linter/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(File.expand_path(__dir__)) { `git ls-files -z`.split("\x0") }

  spec.files         = files.reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
end
