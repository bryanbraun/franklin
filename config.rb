require 'middleman-navtree'
# require 'middleman-linkswap'
#activate :linkswap

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
      return match[1] + ' | ' + data.book.title
    else
      filename = page.url.split(/\//).last.gsub('%20', ' ').titleize
      return filename.chomp(File.extname(filename)) + ' | ' + data.book.title
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

# Configuration For Themes
set :layouts_dir, 'themes/' + data.book.theme.downcase + '/layouts'
set :css_dir, 'themes/' + data.book.theme.downcase + '/stylesheets'
set :js_dir, 'themes/' + data.book.theme.downcase + '/javascripts'
set :images_dir, 'images'
set :source, 'source'

# Ignore all themes, except our selected one, from build.
ignore(/themes\/(?!#{data.book.theme.downcase}).*/)
# Ignore all theme layouts from the sitemap (prevents SystemStackError).
# See also: https://github.com/middleman/middleman/issues/1243
config.ignored_sitemap_matchers[:layout] = proc { |file|
  file.start_with?(File.join(config.source, 'layout.')) || file.start_with?(File.join(config.source, 'layouts/')) || !!(file =~ /themes\/.*\/layouts\//)
}

# Disable layout on the sitemap page.
page "/sitemap.xml", :layout => false

# ?
set :trailing_slash, 'false'

# Define settings for syntax highlighting. We want to mimic Github Flavored
# markdown, so we're using Redcarpet, with some specific settings.
# See https://github.com/blog/832-rolling-out-the-redcarpet
activate :syntax
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :relative_assets # Relative assets are important for publishing on Github.
activate :navtree do |options|
  options.ignore_files = ['readme.md', 'README.md', 'readme.txt', 'license.md', 'CNAME', 'robots.txt', 'humans.txt', '404.md']
  options.ignore_dir = ['themes']   # All the config directories are automatically ignored.
  options.promote_files = ['index.md']
  options.home_title = 'Front Page'
  options.ext_whitelist = ['.md', '.markdown', '.mkd']
end

# Notes
#
# We leave :directory_indexes inactive, so internal markdown links between pages
# will not break.
# activate :directory_indexes

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