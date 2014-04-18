require 'pry-remote'
require 'pp'
require 'middleman-navtree'

activate :navtree do |options|
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
  options.ext_whitelist = ['.html']
end

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
  # 1) Use the title from frontmatter metadata, or
  # 2) peek into the page to find the H1, or
  # 3) fallback to a filename-based-title
  #
  # I can remove this helper from config.rb if I ensure that the Franklin
  # Depends on NavTree. I am 90% sure that will be the case because of how
  # I print navTrees in layouts.
  def discover_title(page = current_page)
    if page.data.title
      return page.data.title # Frontmatter title
    elsif match = page.render({:layout => false}).match(/<h.+>(.*?)<\/h1>/)
      return match[1]
    else
      filename = page.url.split(/\//).last.titleize
      return filename.chomp(File.extname(filename))
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
# set :layouts_dir, 'layouts/glide'
# set :layouts_dir, 'layouts/hamilton'
 set :layouts_dir, 'layouts/epsilon'

set :css_dir, 'stylesheets'
set :js_dir, 'javascript'
set :images_dir, 'images'


# Changing source file, for organizational purposes, and flexibility in defining source locations.
# This causes some defaults to break, so I'll need to explicitly define other settings
set :source, "source"
#set :source, "source/book"

# set :index_file, 'book/index.html' # <---- This setting seems to throw off navigation tree traversal when on.

# Pretty URLs. For more info, see http://middlemanapp.com/pretty-urls/
# activate :directory_indexes # <--- Need to add support for this to NavTree extension.
# set :trailing_slash, 'false'

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

