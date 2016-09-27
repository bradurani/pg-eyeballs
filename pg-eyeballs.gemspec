# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eyeballs/version'

Gem::Specification.new do |spec|
  spec.name          = "pg-eyeballs"
  spec.version       = Eyeballs::VERSION
  spec.authors       = ["Brad Urani"]
  spec.email         = ["bradurani@gmail.com"]

  spec.summary       = 'A Ruby gem for using the postgres explain command with Active Record' 
  spec.description   = 'pg-eyeballs is a ruby gem that gives you detailed information about how the SQL queries created by the active record code you write are executed by the database. It gives you an easy, ruby friendly way to see the output of the Postgres EXPLAIN command and integrates with the popular query analysis tool gocmdpev'
  spec.homepage      = "http://github.com/bradurani/pg-eyeballs"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner"

  spec.add_dependency "activerecord", ">=4.0", "<5.0"
  spec.add_dependency "pg"

end
