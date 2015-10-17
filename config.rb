#####################################################
# Franklin specific Settings -- Do not change
#####################################################

require 'middleman-navtree'

# Configuration For Themes
set :layouts_dir, 'themes/' + data.book.theme.downcase + '/layouts'
set :css_dir, 'themes/' + data.book.theme.downcase + '/stylesheets'
set :js_dir, 'themes/' + data.book.theme.downcase + '/javascripts'
set :images_dir, 'images'
set :source, 'source'

# Disable layout on the sitemap page.
page "/sitemap.xml", :layout => false

# Take steps to ignore the themes we aren't using, including:
# 1. Ignore the unchosen themes so they aren't built.
# 2. Ignore ALL theme layouts from the sitemap (prevents SystemStackError). See also: https://github.com/middleman/middleman/issues/1243
ignore(/themes\/(?!#{data.book.theme.downcase}).*/)
config.ignored_sitemap_matchers[:layout] = proc { |file|
  file.start_with?(File.join(config.source, 'layout.')) || file.start_with?(File.join(config.source, 'layouts/')) || !!(file =~ /themes\/.*\/layouts\//)
}

# Markdown Settings. The specified options render Github Flavored markdown.
# See https://github.com/blog/832-rolling-out-the-redcarpet,
#     https://help.github.com/articles/github-flavored-markdown,
# and https://github.com/vmg/redcarpet.
activate :syntax
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :no_intra_emphasis => true, :autolink => true, :strikethrough => true, :tables => true

# Relative links and assets are important for publishing on Github.
set :relative_links, true
activate :relative_assets
activate :navtree do |options|
  options.ignore_files = ['readme.md', 'README.md', 'readme.txt', 'license.md', 'CNAME', 'robots.txt', 'humans.txt', '404.md']
  options.ignore_dir = ['themes']   # All the config directories are automatically ignored.
  options.promote_files = ['index.md']
  options.home_title = 'Front Page'
  options.ext_whitelist = ['.md', '.markdown', '.mkd']
end

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
    elsif match = page.render({:layout => false, :no_images => true}).match(/<h.+>(.*?)<\/h1>/)
      return match[1] + ' | ' + data.book.title
    else
      filename = page.url.split(/\//).last.gsub('%20', ' ').titleize
      return filename.chomp(File.extname(filename)) + ' | ' + data.book.title
    end
  end

  # A helper that wraps link_to, and only creates the link if it exists in
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

# Notes
#
# We leave :directory_indexes inactive, so internal markdown links between pages
# will not break.
# activate :directory_indexes

#####################################################
# End Franklin specific configuration
#####################################################
