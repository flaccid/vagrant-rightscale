source "https://rubygems.org"

gemspec

# Necessary to run `bundle exec rake`
gem 'rake'

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git", :tag => "v1.2.7"
end
