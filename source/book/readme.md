# Example Book

This is an example of what it might look like to host the contents of a book on Github. If you have cloned this project, you may replace this README with your own. Otherwise, this README will explain how a book repository works, with Bitbooks.

## What goes in this book repository?

Only one thing: **Book content**

This content takes three main forms:

1. The front page (`index.md`)
2. Additional pages
3. Images

There must be a page named `index.md`, which will be used to make the front page of your book. Each additional page is represented by a separate `.md` file and can be named whatever you please.

**The content of all pages should be written in Markdown.** Each page (including the front page) should begin with a heading (represented in markdown by `# Title`). This heading will be used to lable the page in the book's table of contents. If you do not have a heading on the page, Bitbooks will use the filename to generate this information.

If you want to put images in your book, we recommend that you upload your images to an `images` folder for referencing within your book's pages. Examples on how to do this can be found in [styleguide.md](styleguide.md).

### What is Markdown?

Markdown is a simple format for writing on the web. Markdown content is written with a text editor and saved as files named like `filename.md` (or alternatively `filename.markdown`). If you are unfamiliar with markdown, here are some [basic instructions for getting started](https://help.github.com/articles/markdown-basics).

## Directory Structure

Bitbooks makes very few assumptions about how your repository should be structured. You can create a flat list of markdown files, or you can choose to use directories to organize your book content, like the "chapter" folders in this example.

The structure of your Bitbooks site will mimic the structure of this repository. Here are a few example directory structures, with the resulting impact on book navigation and urls:

(image 1)

(image 2)

(image 3)

You may have noticed that page order is defined by alphebetical sorting of the filename. For this reason, we usually recommend prepending filenames with numbers for sorting purposes. The only exception to this is `index.md` which will always be sorted first to be used as the front page.

## Styleguide

You can see markdown usage examples in [styleguide.md](styleguide.md). This demonstrates how to reference images from your images folder, include code snippets, use html for advanced formatting (like tables or video embeds), and more.
