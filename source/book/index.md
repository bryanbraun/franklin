# Front Page

This is the front page of your book. It can be reached by clicking the first link in the table of contents or by clicking the title of the book (on any page). This file must be named `index.md`.

Foo. foo. foo. foo.
Bar. bar. bar. bar.

## Code Snippet Examples

Ruby

```ruby
# This is a comment
class Date
  def distance_to(end_date)
    years = end_date.year - "year"
    if months < 0
      months += 12
      test = Class::Object.method
      string = "This is a very long string"
    end
    {:years => years, :months => months, :days => days}
  end
end
```

```html
<html>
  <head><title>Title!</title></head>
  <body>
    <p id="foo">Hello, World!</p>
    <script type="text/javascript">var a = 1;</script>
    <style type="text/css">#foo { font-weight: bold; }</style>
  </body>
</html>
```

```java
public class java {
    public static void main(String[] args) {
        System.out.println("Hello World");
    }
}
```




The first thing at the beginning of each page (including the front page) should be a heading (represented in markdown by `# Title`). This heading will be used in the table of contents and the page title (on the browser tab). If you do not have a heading on the page, bitbooks will use the filename to generate this information.

You can see how various elements are designed in this theme, by looking at [the styleguide page](styleguide.md).