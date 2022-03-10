require "rake"
require "rspec/core/rake_task"

desc 'Test VOODOO'
RSpec::Core::RakeTask.new(:test) do |t|
    t.rspec_opts = ['-f d']
end

desc 'Uninstall VOODOO'
task :uninstall do
  puts `gem uninstall get-voodoo`
end

desc 'Uninstall, re-build, and install'
task :dev do
  `gem uninstall get-voodoo`
  puts `bundle install`
  puts `gem build ./voodoo.gemspec`
  puts `gem install ./get-voodoo-0.0.3.gem --user-install && rm ./get-voodoo-0.0.3.gem`
end

desc 'Build VOODOO'
task :build do
    `gem build ./voodoo.gemspec`
end

task :default => :test