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

  # Helper for building a content tree
  # Accepts a single sitemap resource.
  def content_tree(page)
    if page.children
      # tag :ul, :class => 'level', true
      page.children.each do |child_page| 
        content_tree(child_page)
      end
      return "<p>last child page reached</p>"
      # return "</ul>"
    else
      return "<p>page has no children</p>"
      # return "<li>" + link_to(page_title(page), page) + "</li>"
    end
    return "<span>it worked</span>"
  end

end

set :css_dir, 'stylesheets/glide'
set :js_dir, 'javascripts'
set :images_dir, 'images'
# set :index_file, 'book/index.html' # <---- This setting seems to throw off the navigation tree when on.

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
