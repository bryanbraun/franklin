# Front Page

This is the front page of your book. It can be reached by clicking the first link in the table of contents or by clicking the title of the book (on any page). This file must be named `index.md`.

Now we will link to a lot of different stuff, to test our linkswap.

1. Standard relative MD Link: [Styleguide](styleguide.md)
2. Root-relative MD Link: [Styleguide](/book/styleguide.md)
3. Deep relative MD link: [Early Writings](chapter-1/section-1.1/1-early-writings.md)
4. Standard HTML Link: [Styleguide](styleguide.html)
5. Root-relative HTML Link: [Styleguide](/book/styleguide.html)
6. Fake decoy link 1: [Styleguide](test.mdstyleguide.md)
7. Fake decoy link 2: [Styleguide](cmd.md)
8. Fake decoy link 3: [Styleguide](../md/test.md)
9. Fake decoy link 4: [Styleguide](../md/test.md)
10. Fake decoy link 5: blah blah styleguide.md blah. Also blah `styleguide.md` blah blah.
11. Link in code snippet:

```
# Snippet containing styleguide.md references
if filename == 'styleguide.md'
  path << "styleguide.md"
end
```

```ruby
# Snippet containing styleguide.md references
if filename == 'styleguide.md'
  path << "styleguide.md"
end
```

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