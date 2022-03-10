require "rake"
require "rspec/core/rake_task"

desc 'Test VOODOO'
RSpec::Core::RakeTask.new(:test) do |t|
    t.rspec_opts = ['-f d']
end

desc 'Uninstall VOODOO'
task :uninstall do
  puts `gem uninstall voodoo`
end

desc 'Uninstall, re-build, and install'
task :dev do
  `gem uninstall voodoo`
  puts `bundle install`
  puts `gem build ./voodoo.gemspec`
  puts `gem install ./VOODOO-0.0.1.gem --user-install && rm ./VOODOO-0.0.1.gem`
end

task :default => :test