# Code Highlighter

Franklin uses [Rouge](http://rouge.jneen.net/) library for code highlighting.

Below You can find some examples of code highlight.

## Pre content

    Lorem Ipsum is simply dummy text of the printing and typesetting industry.
    Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,
    when an unknown printer took a galley of type and scrambled it to make a type specimen book.

## Shell

```shell
ls -la
cd directory
```

## Ruby

```ruby
markdown = Redcarpet.new("Hello World!")

puts markdown.to_html

class NewClass
  def initialize(options)
    @options = options
  end
end
```

## Javascript

```javascript
var x = myFunction(4, 3);

function myFunction(a, b) {
    return a * b;
}
```
