# If you have OpenSSL installed, we recommend updating
# the following line to use "https"
source 'http://rubygems.org'

gem "middleman", "~> 3.3.2"
gem "middleman-syntax"
gem "redcarpet" # For github-flavored markdown
gem "middleman-navtree"
gem "titleize", "~> 1.3.0" # For title-casing things
# gem "middleman-linkswap" # Not including for now.

# For faster file watcher updates on Windows:
gem "wdm", "~> 0.1.0", :platforms => [:mswin, :mingw]

group :development do
  gem "middleman-livereload", "~> 3.1.0"
  gem "pry"
end

# Cross-templating language block fix for Ruby 1.8
platforms :mri_18 do
  gem "ruby18_source_location"
end