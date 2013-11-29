####################################
# TRYING AN EXTENSTION. WHOOO HOO!
####################################
require 'yaml'

class SourceTree < Middleman::Extension
  # All the options for this extension
  option :source_dir, 'source', 'The directory our tree will begin at.'
  option :data_file, 'data/tree.yml', 'The file we will write our directory tree to.'
  option :ignore_files, '', 'A list of filenames we want to ignore when building our tree.'
  option :ignore_dir, '', 'A list of directory names we want to ignore when building our tree.'

  def initialize(app, options_hash={}, &block)
    super
    tree_hash = scan_directory(options.source_dir, options)

    # This global variable is bad, but it's in place until I can find a better way
    # to deal with duplicate file names.
    $duplicate_file_cache = []
    
    # write our directory tree to file as YAML.
    IO.write(options.data_file, YAML::dump(tree_hash)) 
  end

  # Method for storing the directory structure in a hash.
  def scan_directory(path, options, name=nil)
    data = {}
    data["#{(name || path)}"] = children = []
    Dir.foreach(path) do |filename|
      next if (filename == '..' || filename == '.')
      # Check to see if we should ignore this file.
      next if options.ignore_files.include? filename
      full_path = File.join(path, filename)
      if File.directory?(full_path)
        # This item is a directory.
        # Check to see if we should ignore this directory.
        next if options.ignore_dir.include? filename

        # Loop through the method again.
        children << scan_directory(full_path, options, filename)
      else
        # This item is a file... store the filename.
        children << filename
      end
    end
    return data
  end

  # Helpers for use in templates
  helpers do

    #  Recursive helper for converting source tree data from a ruby hash into HTML
    #  If this is released publicly, I think it would have to be packaged together. SourceTree + Hash_to_html (tree_data_to_html?) + discover_title
    #  I've got to think about if this solves issues that traversal doesn't.

    def data_to_html(value, key=nil)
        html = ''
        if value.is_a?(String)
          # This is a child item (a file). Get the Sitemap resource for this file.
          # this_resource = sitemap.resources.find{|r| r.source_file.match(/#{value}/) }
          this_resource = get_resource_from_tree(value)
          # Define string for active states.
          active = this_resource == current_page ? 'active' : ''
          title = discover_title(this_resource)
          html << "<li class='child #{active}'><a href='#{this_resource.url}'>#{title}</a></li>"
        elsif value.is_a?(Hash)
          # This is a parent item (a directory)
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

    #1
    # Print flat sitemap
    # def print_sitemap(page = current_page)
    #  return flat_sitemap
    # end

  end

end

::Middleman::Extensions.register(:source_tree, SourceTree)

activate :source_tree do |options|
  options.source_dir = 'source/book'
  options.data_file = 'data/tree.yml'
  options.ignore_files = ['readme.md', 'readme.txt', 'license.md']
  options.ignore_dir = ['images', 'img', 'image', 'assets']
end

####################################
# END OF EXTENSION. WHOOO HOO!
#######################################



####################################
# TRYING AN EXTENSTION. WHOOO HOO!
####################################

class NextPrevious < Middleman::Extension
  #2
  #option :tree_data, {}, 'A reference to a yaml file in /data containing structured directory-tree content.'
  option :ignore, [], 'A list of filenames to ignore when creating a sitewide pagination pagelist.'

  def initialize(app, options_hash={}, &block)
    super
    @@page_list = []

    #2 
    # @@page_list = flatten_source_tree(options.tree_data)
  end

  #1 Trying to pull data out of sitemap. It's working but I'm having trouble getting it into helpers.
  #
  def manipulate_resource_list(resources)
    resources.each do |resource|
      if resource.path.include? ".html"
        source_file_array = resource.source_file.split('/')
        next if options[:ignore].include? source_file_array[-1]
        @@page_list.push(resource.path)
        puts @@page_list
      end
    end
  end


#2 Working methods for the "flatten the sourcetree" Technique. Temporarily commented to try the sitemap technique
# Because the duplicate file prevention issue complicates things when using this method.
=begin
  def manipulate_resource_list(resources)

    # Replace filenames in the page_list variable with full paths in our page_list, for easier referencing.
    @@page_list.each_with_index do |filename, index|
    puts @@page_list[index]
    this_resource = resources.find{|r| r.source_file.match(/#{filename}/) }
    # This duplicate prevention tool isn't working yet because it cannot call a helper method from here.
    #this_resource = get_resource_from_tree(filename) 
      unless this_resource.nil?
        @@page_list[index] = this_resource.path
        puts @@page_list[index]
      end
    end

    return resources
  end

  # An idea for flattening the source tree
  def flatten_source_tree(value, k = [], depth = 0, flat_tree = [])

      if value.is_a?(String)
        # This is a child item (a file).
        flat_tree.push(value)
      elsif value.is_a?(Hash)
        # This is a parent item (a directory).
        value.each do |key, child|
          flatten_source_tree(child, key, depth + 1, flat_tree)
        end

      elsif value.is_a?(Array)
        # This is a collection. It could contain files, directories, or both.
        value.each_with_index do |item, key|
          flatten_source_tree(item, key, depth + 1, flat_tree)
        end
      end

      return flat_tree
  end
=end

  # Helpers for use in templates
  helpers do

    def test_helper
      puts defined?(@@page_list) ? @@page_list : "help: pagelist false" #=> false
    end

    def get_current_position_in_page_list
      @@page_list.each_with_index do |page_path, index|
        if page_path == current_page.path
          return index
        end
      end
    end

    def previous_link
      prev_page = @@page_list[get_current_position_in_page_list() - 1]
      options = {:class => "previous"}
      unless first_page?
        link_to("Previous", "/" + prev_page, options)
      end
    end

    def next_link
      next_page = @@page_list[get_current_position_in_page_list() + 1]
      options = {:class => "next"}
      unless last_page?
        link_to("Next", "/" + next_page, options)
      end
    end

    def first_page?
      return true if get_current_position_in_page_list() == 0
    end

    def last_page?
      return true if @@page_list[get_current_position_in_page_list()] == @@page_list[-1]
    end

  end

end

::Middleman::Extensions.register(:next_previous, NextPrevious)

#2
# activate :next_previous, tree_data: data['tree']
activate :next_previous, ignore: ['README.md', 'readme.md', 'license.md']


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

  # A utility function for checking duplicate file names when iterating through the tree (see 'Known 
  # issues' in my notes). This may not work as well if it is being used to find a one-off filename 
  # because the cache clear assumes that if all filepaths are cached it needs to be refreshed.
  # For now, I'm not using like that, so while this isn't elegant, it should work without bugs.
  def get_resource_from_tree(filename)
    unique_resources = sitemap.resources.find_all{|r| r.source_file.match(/#{filename}/) }
    if unique_resources.size >= 2
      # There were multilple files in the tree with the same filename. Lets loop thought them.
      unique_resources.each_with_index do |resrc, index|
        if $duplicate_file_cache.include? resrc.path
          if resrc == unique_resources.last
            # All files matching the filename are in the cache, which means
            # The cache is still full from the last iteration through the tree
            # and needs to be cleared.
            $duplicate_file_cache.clear
            # Retest the same file name.
            return get_resource_from_tree(filename)
          end
          next
        else
          $duplicate_file_cache.push(resrc.path)
          return resrc
        end
      end
    elsif unique_resources.size == 1
      return unique_resources[0];
    else
      throw "This filename is not in the source tree."
    end
  end

end

# An attempt to fix links to images from content, and links to assets outside the source folder.
# To be honest, I can't see what this is really doing.
# set :relative_links, true

set :css_dir, 'stylesheets/glide'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :layouts_dir, 'layouts'

# Changing source file, for organizational purposes, and flexibility in defining source locations.
# This causes some defaults to break, so I'll need to explicitly define other settings
set :source, "source"
#set :source, "source/book"

# set :index_file, 'book/index.html' # <---- This setting seems to throw off navigation tree traversal when on.

# Pretty URLs. For more info, see http://middlemanapp.com/pretty-urls/
#activate :directory_indexes
#set :trailing_slash, 'false'

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



