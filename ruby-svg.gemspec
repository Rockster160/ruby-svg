# frozen_string_literal: true

require_relative "lib/ruby-svg/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-svg"
  spec.version = SVG::VERSION
  spec.authors = ["Rocco Nicholls"]
  spec.email = ["rocco11nicholls@gmail.com"]

  spec.summary = "Simply Ruby wrapper to generate SVG files"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/Rockster160/ruby-svg"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rockster160/ruby-svg"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)|.gem$})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
