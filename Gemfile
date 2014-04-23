# If you have OpenSSL installed, we recommend updating
# the following line to use "https"
source 'http://rubygems.org'
ruby '1.9.3' # Added by Bryan, for labeling the version of Ruby we are using.

gem "middleman", "~> 3.3.2"

# For syntax highlighting with redcarpet
gem "middleman-syntax"
gem "redcarpet"

# Live-reloading plugin
gem "middleman-livereload", "~> 3.1.0"

# For title-casing things
gem "middleman-navtree", path: "/Users/bryan.braun/Code/bryanbraun/middleman-navtree"
gem "titleize", "~> 1.3.0"
gem "middleman-linkswap", path: "/Users/bryan.braun/Code/bryanbraun/middleman-linkswap"


# For faster file watcher updates on Windows:
gem "wdm", "~> 0.1.0", :platforms => [:mswin, :mingw]

# For debugging
gem "pry"
gem "pry-remote"
gem 'pry-debugger'
gem "pry-doc"

# Cross-templating language block fix for Ruby 1.8
platforms :mri_18 do
  gem "ruby18_source_location"
end