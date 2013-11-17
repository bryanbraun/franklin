####################################
# TRYING AN EXTENSTION. WHOOO HOO!
####################################
require 'yaml'

class SourceTree < Middleman::Extension
  # All the options for this extension
  option :source_dir, 'source', 'The directory our tree will begin at.'
  option :data_file, 'data/tree.yml', 'The file we will write our directory tree to.'
  option :ignore, '', 'A list of filenames we want to ignore when building our tree.'

  def initialize(app, options_hash={}, &block)
    super
    tree_hash = directory_hash(options.source_dir, options)
    
    # write our directory tree to file as YAML.
    IO.write(options.data_file, YAML::dump(tree_hash)) 
  end

  # Method for storing the directory structure in a hash.
  def directory_hash(path, options, name=nil)
    data = {}
    data["#{(name || path)}"] = children = []
    Dir.foreach(path) do |filename|
      next if (filename == '..' || filename == '.')
      # Check to see if we should ignore this file.
      next if options.ignore.include? filename
      full_path = File.join(path, filename)
      if File.directory?(full_path)
        # This item is a directory... loop through the method again.
        children << directory_hash(full_path, options, filename)
      else
        # This item is a file... store the filename.
        children << filename
      end
    end
    return data
  end

end

::Middleman::Extensions.register(:source_tree, SourceTree)

activate :source_tree do |options|
  options.source_dir = 'source/book'
  options.data_file = 'data/tree.yml'
  options.ignore = ['readme.md', 'readme.txt', 'license.md']
end

####################################
# END OF EXTENSION. WHOOO HOO!
#######################################


###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Disable layout on the sitemap page.
page "/sitemap.xml", :layout => false

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
helpers do

  # Helper for getting the page title
  # Based on this: http://forum.middlemanapp.com/t/using-heading-from-page-as-title/44/3
  # Use the title from frontmatter metadata,
  # or peek into the page to find the H1,
  # or fallback to a filename-based-title

  def discover_title(page = current_page)
    if frontmatter_title = page.data.title
      return frontmatter_title
    elsif match = page.render({layout: false}).match(/<h.+>(.*?)<\/h1>/)
      return match[1]
    else
      return page.url.split(/\//).last.titleize
    end
  end

  #  Recursive helper for converting source tree data from a ruby hash into HTML
  #  If this is released publicly, I think it would have to be packaged together. SourceTree + Hash_to_html (tree_data_to_html?) + discover_title
  #  I've got to think about if this solves issues that traversal doesn't.

  def data_to_html(value, key=nil)
      html = ''
      if value.is_a?(String)
        # This is a child item (file). Get the Sitemap resource for this file.
        this_resource = sitemap.resources.find{|r| r.source_file.match(/#{value}/) }
        # Define string for active states.
        active = this_resource == current_page ? 'active' : ''
        title = discover_title(this_resource)
        html << "<li class='child #{active}'><a href='#{this_resource.url}'>#{title}</a></li>"
      elsif value.is_a?(Hash)
        # This is a parent item (directory)
        dir_name = key.nil? ? value.keys[0] : key

        html << "<li class='parent'><span class='parent-label'>#{dir_name.gsub(/-/, ' ').gsub(/_/, ' ').titleize}</span>"
        html << '<ul>'
        value.each do |key, child|
          html << data_to_html(child, key)
        end
        html << '</ul>'
        html << '</li>'
      elsif value.is_a?(Array)
        # This is a collection. It could contain files, directories, or both.
        value.each do |y|
          html << data_to_html(y)
        end
      end

      return html
  end

end

set :css_dir, 'stylesheets/glide'
set :js_dir, 'javascripts'
set :images_dir, 'images'
# set :index_file, 'book/index.html' # <---- This setting seems to throw off navigation tree traversal when on.

# Pretty URLs. For more info, see http://middlemanapp.com/pretty-urls/
activate :directory_indexes
set :trailing_slash, 'false'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end



