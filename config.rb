####################################
# TRYING AN EXTENSTION. WHOOO HOO!
####################################
require 'yaml'

class SourceTree < Middleman::Extension
  # All the options for this extension
  option :source_dir, 'source', 'The directory our tree will begin at.'
  option :data_file, 'data/tree.yml', 'The file we will write our directory tree to.'
  option :exceptions, '', 'A list of filenames we want to ignore when building our tree.'

  def initialize(app, options_hash={}, &block)
    super
    tree_hash = directory_hash(options.source_dir, options)
    
    # write our directory tree to file as YAML.
    IO.write(options.data_file, YAML::dump(tree_hash)) 
  end

  # Method for storing the directory structure in a hash.
  def directory_hash(path, options, name=nil)
    # Maybe I can put something like "unless path == :source_dir, print the directory and and children labels."
    # This would prevent the printing of the top level items.
    #puts path
    #puts options.source_dir
    #unless path == options.source_dir
      data = {"directory" => (name || path)}
      data["children"] = children = []
    #else
      #data = children = []
    #end
    Dir.foreach(path) do |entry|
      next if (entry == '..' || entry == '.')
      # Do not log any exceptions
      next if options.exceptions.include? entry
      full_path = File.join(path, entry)
      if File.directory?(full_path)
        children << directory_hash(full_path, options, entry)
      else
        children << entry
      end
    end
    return data
  end

end

::Middleman::Extensions.register(:source_tree, SourceTree)

activate :source_tree do |options|
  options.source_dir = 'source/book'
  options.data_file = 'data/tree.yml'
  options.exceptions = ['readme.md', 'readme.txt', 'license.md']
end

####################################
# END OF EXTENSION. WHOOO HOO!
#######################################


# Define a source tree hash for use in helpers/templates
@source_tree = data['tree']
@source_tree_down_one = data['tree']['children']





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
  #  @TODO: Exception for README file (I think this would be a good option in the original extension)
  #  @TODO: Don't print first parent directory (either here or when first storing the data... leaning towards fixing it on the storage side).
  #  @TODO: Compare my nav list to other common site navs. I don't think it's quite nested perfectly. I think non-link
  #         directory lables should be in spans, and nested ul's don't need to be inside li's. Just look into it.
  #  If this is released publicaly, I think it would have to be packaged together. SourceTree + Hash_to_html (tree_data_to_html?) + discover_title
  #  I've got to think about if this solves issues that traversal doesn't.

  def hash_to_html(hash)
      html = ''
      if hash.is_a?(String)
        # This is a child item (file). Get the Sitemap resource for this file.
        this_resource = sitemap.resources.find{|r| r.source_file.match(/#{hash}/) }
        # Define string for active states.
        active = this_resource == current_page ? 'active' : ''
        title = discover_title(this_resource)
        html << "<li class='child #{active}'><a href='#{this_resource.url}'>#{title}</a></li>"
      elsif hash.is_a?(Hash)
        # This is a parent item (directory)
        html << "<li class='parent'><span class='parent-label'>#{hash['directory'].gsub(/-/, ' ').gsub(/_/, ' ').titleize}</span>"
        html << '<ul>'
        hash['children'].each do |child|
          html << hash_to_html(child)
        end
        html << '</ul></li>'
      elsif hash.is_a?(Array)
        # This is a collection. It could contain files, directories, or both.
        hash.each do |y|
          html << hash_to_html(y)
        end
      end

      return html
  end

# ORIGINAL
#  def hash_list_tag(hash)
#    html = content_tag(:ul) {
#      ul_contents = ""
#      ul_contents << content_tag(:li, hash[:parent])
#      hash[:children].each do |child|
#        ul_contents << hash_list_tag(child)
#      end
#
#      ul_contents.html_safe
#    }.html_safe
#  end

#  Helper for converting source tree into HTML
#  def hash_to_html key,value
#    if value.nil?
#      return "<li>#{key}</li>"
#    elsif value.is_a?(Hash)
#      string = "<li>#{key}"
#      string << "<ul>"
#      string << value.each(&method(:hash_to_html))
#      string << "</ul></li>"
#      return string
#    else
#      puts "I don't know what to do with a #{value.class}"
#    end
#  end

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



