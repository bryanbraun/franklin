require 'pry'
require 'pry-remote'
require 'pp'
require 'middleman-navtree'
require 'middleman-linkswap'

# Disable layout on the sitemap page.
page "/sitemap.xml", :layout => false

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

# Methods defined in the helpers block are available in templates
helpers do

  # Helper for getting the page title
  # Based on this: http://forum.middlemanapp.com/t/using-heading-from-page-as-title/44/3
  # 1) Use the title from frontmatter metadata, or
  # 2) peek into the page to find the H1, or
  # 3) IF this is the title page, use the Book title, or
  # 4) fallback to a filename-based-title
  def discover_page_title(page = current_page)
    if page.data.title
      return page.data.title # Frontmatter title
    elsif page.url == '/'
      return data.book.title
    elsif match = page.render({:layout => false}).match(/<h.+>(.*?)<\/h1>/)
      return match[1]
    else
      filename = page.url.split(/\//).last.titleize
      return filename.chomp(File.extname(filename))
    end
  end


  # A helper that wraps link_to, and tests to see if a provided link exists in
  # the sitemap. Used for page titles.
  def link_to_if_exists(*args, &block)
    url = args[0]

    resource = sitemap.find_resource_by_path(url)
    if resource.nil?
      block.call
    else
      link_to(*args, &block)
    end
  end

end

# An attempt to fix links to images from content, and links to assets outside the source folder.
# To be honest, I can't see what this is really doing.
set :relative_links, true

# @todo: Consider fixing it so a site build will contain assets from other themes
# @todo: Break up the themes to be more consolodated? Good for Franklin, I think.
# set :layouts_dir, data.book.theme.downcase + '/layouts'
# set :css_dir, data.book.theme.downcase + '/stylesheets'
# set :js_dir, data.book.theme.downcase + '/javascript'
# set :images_dir, 'images'
set :layouts_dir, 'layouts/' + data.book.theme.downcase
set :css_dir, 'stylesheets'
set :js_dir, 'javascript'
set :images_dir, 'images'
set :source, "source"

# Pretty URLs. For more info, see http://middlemanapp.com/pretty-urls/
# activate :directory_indexes
set :trailing_slash, 'false'

# Define settings for syntax highlighting. We want to mimic Github Flavored
# markdown, so we're using Redcarpet, with some specific settings.
# See https://github.com/blog/832-rolling-out-the-redcarpet
activate :syntax
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :relative_assets # Relative assets are important for publishing on Github.
activate :linkswap
activate :navtree do |options|
  options.source_dir = 'source'
  options.data_file = 'data/tree.yml'
  options.ignore_files = ['readme.md', 'README.md', 'readme.txt', 'license.md', 'CNAME', 'robots.txt', 'humans.txt', '404.md']
  # All the config directories are automatically added.
  options.ignore_dir = ['layouts']
  # @todo: You cannot promote two files with the same name, because they can't have the same key
  #        on the same level in the same hash. I should decide whether I care. One option is to pass
  #        in full filepaths (or do this with a hash, similar to how I did with the tree).
  options.promote_files = ['index.md']
  options.home_title = 'Front Page'
  options.ext_whitelist = ['.md', '.markdown', '.mkd']
end


# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Or use a different image path
  # @todo: see if there is any value in integrating this with the "images" folder.
  # set :http_prefix, "/Content/images/"
end

