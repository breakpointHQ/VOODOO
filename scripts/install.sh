bundle install
gem uninstall voodoo
gem build ./voodoo.gemspec
gem install ./VOODOO-0.0.1.gem --user-install
rm ./VOODOO-0.0.1.gem