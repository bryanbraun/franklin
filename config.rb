require 'pry-remote'
require 'pp'

####################################
# TRYING AN EXTENSTION. WHOOO HOO!
####################################
require 'yaml'
require 'titleize'

class SourceTree < Middleman::Extension
  # All the options for this extension
  option :source_dir, 'source', 'The directory our tree will begin at.'
  option :data_file, 'data/tree.yml', 'The file we will write our directory tree to.'
  option :ignore_files, '', 'A list of filenames we want to ignore when building our tree.'
  option :ignore_dir, '', 'A list of directory names we want to ignore when building our tree.'
  option :promote_files, '', 'A list of files you want to push to the front of the tree (if they exist).'

  def initialize(app, options_hash={}, &block)
    super

    @existing_promotes = []

    tree_hash = scan_directory(options.source_dir, options)

    tree_hash = promote_files(tree_hash, options)

    # Write our directory tree to file as YAML.
    # @todo: This step doesn't rebuild during live-reload, which causes errors if you move files
    #        around during development. It may not be that hard to set up. Low priority though.
    IO.write(options.data_file, YAML::dump(tree_hash))

  end

  # Method for storing the directory structure in a hash.
  # @todo: find a more elegant solution than just replacing ".md" with ".html",
  #        so it works for the other types of template files that middleman supports, and doesn't
  #        act weird on things like .js or .xml files. Required before open source release.
  # @todo: the order of the data is defined by the order in the hash, and technically, ruby hashes
  #        are unordered. This may be more robust if I defined an ordered hash type similar to
  #        this one in Rails: http://apidock.com/rails/ActiveSupport/OrderedHash
  def scan_directory(path, options, name=nil)
    data = {}
    Dir.foreach(path) do |filename|

      # Check to see if we should skip this file. We skip dotfiles, ignored files, and promoted files
      # (which are handled later in the process).
      next if (filename[0] == '.')
      next if (filename == '..' || filename == '.')
      next if options.ignore_files.include? filename
      if options.promote_files.include? filename
        # Transform filepath (/source/directory/file.md => /directory/file.html)
        destination_path = path.sub(/^source/, '') + '/' + filename.chomp(File.extname(filename)) + '.html'
        @existing_promotes << destination_path
        next
      end

      full_path = File.join(path, filename)
      if File.directory?(full_path)
        # This item is a directory.
        # Check to see if we should ignore this directory.
        next if options.ignore_dir.include? filename

        # Loop through the method again.
        data.store(filename, scan_directory(full_path, options, filename))
      else
        # This item is a file... store the destination path.
        # Transform filepath (/source/directory/file.md => /directory/file.html)
        destination_path = path.sub(/^source/, '') + '/' + filename.chomp(File.extname(filename)) + '.html'
        data.store(filename, destination_path)
      end
    end

    return data
  end

  # Method for appending promoted files to the front of our source tree.
  # @todo: Currently, options.promote_files only expects a filename, which means that
  #        if multiple files in different directories have the same filename, they
  #        will both be promoted, and one will not appear (due to the 'no-two-identical
  #        -indices-in-a-hash' rule).
  def promote_files(tree_hash, options)

    if @existing_promotes.any?
      ordered_matches = []
      options.promote_files.each do |filename|
        # Get filename without extension (index.md => index)
        filename_without_ext = filename.chomp(File.extname(filename))
        # Test against each existing_promote, and store matches
        @existing_promotes.each do |pathname|
          # Get another filename without extension from the pathname (/book/index.html => index)
          pathname_without_ext = File.basename(pathname, ".*")
          # Add matches to our ordered matches array.
          if filename_without_ext == pathname_without_ext
            ordered_matches << [filename, pathname]
          end
        end
      end
      # Promote all files found in both the promotes list and the file structure. This is an array
      # of arrays
      ordered_matches.reverse.each do |match|
        tree_hash = Hash[match[0], match[1]].merge!(tree_hash)
      end
    end

    return tree_hash
  end

  # Helpers for use in templates
  helpers do


    #  A recursive helper for converting source tree data from into HTML
    def tree_to_html(value, key=nil)
      html = ''

      if value.is_a?(String)
        # This is a child item (a file). Get the Sitemap resource for this file.
        this_resource = sitemap.find_resource_by_destination_path(value)
        # Define string for active states.
        active = this_resource == current_page ? 'active' : ''
        title = discover_title(this_resource)
        html << "<li class='child #{active}'><a href='#{this_resource.url}'>#{title}</a></li>"
      else
        # This is a directory.
        if key.nil?
          # The first level is the source directory, so it has no key and needs no list item.
          value.each do |newkey, child|
            html << tree_to_html(child, newkey)
          end
        else
          # This directory has a key and should be listed in the page hieararcy with HTML.
          dir_name = key
          html << "<li class='parent'><span class='parent-label'>#{dir_name.gsub(/-/, ' ').gsub(/_/, ' ').titleize}</span>"
          html << '<ul>'

          # Loop through all the directory's contents.
          value.each do |newkey, child|
            html << tree_to_html(child, newkey)
          end
          html << '</ul>'
          html << '</li>'
        end
      end

      return html
    end

    # Helper for building a single level HTML menu out of the source tree.
    def tree_single_level_to_html(value, key=nil)
      html = ''

      if value.is_a?(String)
        # This is a child item (a file). Get the Sitemap resource for this file.
        this_resource = sitemap.find_resource_by_destination_path(value)
        # Define string for active states.
        active = this_resource == current_page ? 'active' : ''
        title = discover_title(this_resource)
        html << "<li class='child #{active}'><a href='#{this_resource.url}'>#{title}</a></li>"
      else
        # This is a directory.
        if key.nil?
          # The first level is the source directory, so it has no key and needs no list item.
          value.each do |newkey, child|
            html << tree_single_level_to_html(child, newkey)
          end
        else
          # Not populating lower level directories recursively.
        end
      end

      return html
    end


    # Pagination helpers
    # @todo: One potential future feature is previous/next links for paginating on a
    #        single level instead of a flattened tree. I don't need it but it seems pretty easy.
    def previous_link(sourcetree)
      pagelist = flatten_source_tree(sourcetree)
      position = get_current_position_in_page_list(pagelist)
      # Skip link generation if position is nil (meaning, the current page isn't in our
      # pagination pagelist).
      if position
        prev_page = pagelist[position - 1]
        options = {:class => "previous"}
        unless first_page?(pagelist)
          link_to("Previous", prev_page, options)
        end
      end
    end

    def next_link(sourcetree)
      pagelist = flatten_source_tree(sourcetree)
      position = get_current_position_in_page_list(pagelist)
      # Skip link generation if position is nil (meaning, the current page isn't in our
      # pagination pagelist).
      if position
        next_page = pagelist[position + 1]
        options = {:class => "next"}
        unless last_page?(pagelist)
          link_to("Next", next_page, options)
        end
      end
    end

    # Helper for use in pagination methods.
    def first_page?(pagelist)
      return true if get_current_position_in_page_list(pagelist) == 0
    end

    # Helper for use in pagination methods.
    def last_page?(pagelist)
      return true if pagelist[get_current_position_in_page_list(pagelist)] == pagelist[-1]
    end

    # Method to flatten the source tree, for use in pagination methods.
    def flatten_source_tree(value, k = [], depth = 0, flat_tree = [])

      if value.is_a?(String)
        # This is a child item (a file).
        flat_tree.push(value)
      elsif value.is_a?(Hash)
        # This is a parent item (a directory).
        value.each do |key, child|
          flatten_source_tree(child, key, depth + 1, flat_tree)
        end
      # @todo: I think we can take this part out when arrays aren't in the
      #        sourcetree anymore.
      elsif value.is_a?(Array)
        # This is a collection. It could contain files, directories, or both.
        value.each_with_index do |item, key|
          flatten_source_tree(item, key, depth + 1, flat_tree)
        end
      end

      return flat_tree
    end

    # Helper for use in pagination methods.
    def get_current_position_in_page_list(pagelist)
      pagelist.each_with_index do |page_path, index|
        if page_path == "/" + current_page.path
          return index
        end
      end
      # If we reach this line, the current page path wasn't in our page list and we'll
      # return false so the link generation is skipped.
      return FALSE
    end

  end
end

::Middleman::Extensions.register(:source_tree, SourceTree)

activate :source_tree do |options|
  options.source_dir = 'source/book'
  options.data_file = 'data/tree.yml'
  options.ignore_files = ['readme.md','readme.txt', 'license.md', 'CNAME', 'robots.txt', 'humans.txt']
  # @todo: I should exclude the layouts, css, js, etc, by default somehow using the config variables.
  #        If people try to print those in their menus, it will choke on the "discover title" funciton
  #        because there's no sitemap resource for those files. I've submitted a question on how to solve
  #        that here: http://forum.middlemanapp.com/t/access-application-configuration/1038/7
  options.ignore_dir = ['images', 'img', 'image', 'assets']
  # @todo: You cannot promote two files with the same name, because they can't have the same key
  #        on the same level in the same hash. I should decide whether I care. One option is to pass
  #        in full filepaths (or do this with a hash, similar to how I did with the tree).
  options.promote_files = ['index.md']
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
    if page.data.title
      return page.data.title # Frontmatter title
    elsif match = page.render({:layout => false}).match(/<h.+>(.*?)<\/h1>/)
      return match[1]
    else
      return page.url.split(/\//).last.titleize
    end
  end



  # A helper that wraps link_to, and tests to see if a provided link exists in the sitemap.
  # Used for page titles.
  def link_to_if_exists(*args, &block)
    url = args[0]

    resource = sitemap.find_resource_by_destination_path(url)
    if resource.nil?
      block.call
    else
      link_to(*args, &block)
    end
  end

end

# An attempt to fix links to images from content, and links to assets outside the source folder.
# To be honest, I can't see what this is really doing.
# set :relative_links, true

# Point to the assets for the site. These paths are theme-specific.
# @todo: See if a site build will contain assets from other themes (bad)
 set :layouts_dir, 'layouts/glide'
# set :layouts_dir, 'layouts/hamilton'
# set :layouts_dir, 'layouts/epsilon'

set :css_dir, 'stylesheets'
set :js_dir, 'javascript'
set :images_dir, 'images'


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

