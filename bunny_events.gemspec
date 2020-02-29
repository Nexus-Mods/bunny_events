lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunny_events/version'

Gem::Specification.new do |spec|
  spec.name          = 'bunny_events'
  spec.version       = BunnyEvent::VERSION
  spec.authors       = ['Dean Lovett']
  spec.email         = ['dean.lovett@nexusmods.com']

  spec.summary       = 'A simple gem to define events for messages queues '
  spec.description   = 'This gem allows the use of "Messages" to be defined and published very easily, without your models/controllers having to worry about how messages are produced. Supports AMQP'
  spec.homepage      = 'https://www.nexusmods.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/Nexus-Mods'
    spec.metadata['changelog_uri'] = 'https://github.com/Nexus-Mods'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny', '>= 2.14.0'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'bunny-mock'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
