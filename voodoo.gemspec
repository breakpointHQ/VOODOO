Gem::Specification.new do |s|
    s.name        = 'get-voodoo'
    s.version     = '0.1.1'
    s.summary     = 'Man in the Browser Framework'
    s.description = 'Man in the Browser Framework'
    s.authors     = ['Ron Masas']
    s.homepage    = 'https://breakpoint.sh/?f=org.rubygems.voodoo'
    s.license     = 'GPL-2.0'
    s.files       = Dir['lib/**/*']
    s.executables = ['voodoo']
    s.require_paths = ['lib']
    s.required_ruby_version = '>= 2.0.0'
    s.metadata    = { 'source_code_uri' => 'https://github.com/breakpointHQ/VOODOO' }
  
    s.add_runtime_dependency 'thor', '~> 1.2'
  
    # Pin development dependencies to specific versions
    s.add_development_dependency 'rake', '~> 13.0'
    s.add_development_dependency 'rspec', '~> 3.11'
    s.add_development_dependency 'bundler', '~> 2.0'
  end