# Franklin

Franklin is a static-site framework, optimized for online books.

Its goal is to do for books, what Octopress has done for blogs.

## Setup

Franklin is built on top of [Middleman](http://middlemanapp.com/), a fantastic static site generator, written in Ruby. Thus the setup steps are as follows:

1. Install Middleman

If you already have Ruby and Rubygems installed (they come installed on on Mac OSX), simply run this from your command line:

    gem install middleman

For more detailed instructions, see http://middlemanapp.com/basics/getting-started/.

2. Download this project, and place it in your ~/.middleman directory:

    git clone git@github.com:bryanbraun/franklin.git ~/.middleman/franklin

3. Create your project:

    # Replace 'mysite' with the name of your project
    middleman init mysite --template=franklin
    cd mysite

4. Install the remaining required gems:

    # You must first install bundler for this command to work
    bundle install

If you do not have bundler installed, go to http://bundler.io/ and check out the project and installation instructions.

## Basic Usage

The most basic purpose of Franklin is to convert a stack of markdown files into an HTML site, and to do it in a way that is optimized for books.

Your markdown files go into the "source" folder. They can be named anything (`xxxxxxxx.md`), except you must have a file named `index.md` to serve as the front page of your book. Franklin starts you out with some example files, which you can change or remove to suit your needs.

The structure of your book, as given in the Table of Contents, will mimic the structure of the markdown files in the source directory. Notably:

1. Your front page (`index.md`) will be promoted to the top of the list.
2. Your readme (`readme.md`) file not appear in your table of contents. (For guidence on how to exclude other items from the Table of Contents, see the README for the [Middleman-Navtree](https://github.com/bryanbraun/middleman-navtree) gem).

When you are ready to build your site, run the following command:

    # This creates a `build` folder, containing your site, converted into static HTML.
    bundle exec middleman build

Using Middleman's customization options, you can do all sorts of interesting things beyond this basic use-case. For details, see the [Middleman documentation](http://middlemanapp.com/).

## Configuration

Your book configuration is written in YAML and kept in /data/book.yml. This is where you can change the author, title, and other book information. The available parameters are (with example values):

    title: Example Book
    author: You
    github_url: https://github.com/bryanbraun/example-book
    github_pages_url: http://bryanbraun.github.io/example-book
    license_name: ''
    license_url: ''

For detailed theming and customization, see [Middleman's documentation](http://middlemanapp.com/)

## Contribution Guidelines

1. [Fork this project](https://github.com/bryanbraun/franklin/fork)
2. Create a feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch to github (`git push origin my-new-feature`)
5. Submit a Pull Request

## Contributors

(your name will go here, if your contribution is accepted)