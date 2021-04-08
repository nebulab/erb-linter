# ERB::Linter

<a href="https://nebulab.it?utm_source=github&utm_medium=badge"><img src="https://img.shields.io/static/v1?label=Nebulab&message=Open+Source&color=%235dbefd&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMQSURBVHgBrZZNTxNRFIbfczsgIMQiLBCRFDaGhUr9A9iiIa5EEneIwE/AlRsNv8KlIKwFl35RTUBX8rFBdiVKAgqmXSCY0M71nJl+zJTOdKh9k6Yzc8/cZ86555x7CQE0mji5hSyGlQoNaOgIPwrnhtIArWszu4EQFudjdR8rzUV+gw8/ZMZB9IwvIwimJJGafhmjWZwFOJ7QkYzWCwTdj+qUDJGKz8Rou3RAlT4YS+hHWW2u/QdM1MNzrI6+zwyXDrg8FANStIDaSXOIJ5whLgAljOIZiglRK6U4vDfz4S2ElGGJWsEaQkCTUbhtNbV+lb+xgFY2Bs9ET0h/GzBxlfAkqnCUKY5xKfVLbsi1/R126lcF6WgCYp2ES42EBp6tvQFY+alLTUlrUxizJEVNWiVwBkVagGg7oe+CDclLYOfrgMdfTBz8PfWa1lkzbsDEsH/5FyF9YUK0zQ1xwpoZtsm9pwxMRLyA9wyi0A2Jcjl1NNqeeEFEimxYPkmWd014ikIDnDTeBb53DOweaRxnvWGyhnmYfPZWGt487sNi6lsK67/lZ1oZGOtUaD3nhtU7etXXfe0VzrzCBgLKCR68rNDX6oaJlvd0xXnklbSfgSTL/QghXF8EP980cVKyVL/Ys9UDVFJa8Tdt+1lYmcmJM3Vd4UEvWeslRf32h9ubrVRl77gBrCto85OfUU+LXTMGx+JuN2Hoin3/Zkfjj6ObBAknV+KG4jpc9BqXMEpiCMz6Z9ZQ12kvJZxb6co4Zr1W83esY8F2OYsIe+eEyfTiVXczCl7uM2wliHfMEJaRc3Wa++mLUotrF4EW7h6f94Dvh6aVFM60Fy8Xkya+BfBOjh5yUWhqY0vmKi9q1GnVxZ7sHKIWSs7FQ71yUagkRTTCfymnVY1gsgHHC5z8hbUjaz0Fr8ZanXhX0pPOw5SrV8wNGjNscMrTKpXKaj05f9twVYHnMZGPHEuwTwEBNi+3NGiNt6GRcsfEIAfhp2cAV3cQLtXoOz7q8+ZJRLx3kmxn4dy7aas1SrfiBpKraV/9A+PSJLDAXLUvAAAAAElFTkSuQmCC"></a>

It's all too easy to introduce errors inside ERB files, unclosed tags, wrong attribute names, bad indentation.

ERB::Linter can check for those errors by turning your ERB tags into HTML-ish tags and run a proper HTML linter on the result:

*original ERB*

```erb
<div>
  <% if @foo == :bar %>
    <%= image_tag(item[:value], alt: item[:value]) %>
  <% elsif @type == :other %>
    <span><%= item[:value] %></span>
  <% else %>
    <% raise "unknown type" %>
  <% end %>
</div>
```

*generated HTML, for linter consumption*

```html
<div>
  <erb silent erb-code=" if @foo == :bar ">
    <erb loud erb-code=" image_tag(item[:value], alt: item[:value]) "></erb>
  </erb>
  <erb silent erb-code=" elsif @type == :other ">
    <span><erb loud erb-code=" item[:value] "></erb></span>
  </erb>
  <erb silent erb-code=" else ">
    <erb silent erb-code=" raise &quot;unknown type&quot; "></erb>
  </erb>
</div>
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'erb-linter'
```

And add `linthtml` to yarn:

    $ yarn add --dev @linthtml/linthtml

## Usage

### From the command line

```bash
ruby -rbundler/setup -rerb/linter -e "exit ERB::Linter::Checker.check_files('app/views/**/*.html.erb')"
```

### As a Rake task

Add a task to your Rakefile:

```ruby
ERB::Linter::Task.new do |task|
  # Change the task name.
  # Default: :erb_linter
  # task.name = 'linter:html'

  # Use a different glob for listing ERB files.
  # Default: '**/*.erb'
  # task.glob = 'app/components/**/*.html.erb'

  # Use a different temp dir for storing the HTML version of your ERB files.
  # Default: Dir.tmpdir
  # task.tmpdir = Rails.root.join('tmp')
end
```

### Example linthtml configuration

And then add a `linthtml` configuration like this:

`.linthtmlrc.js`

```js
module.exports = {
  maxerr: false,
  "raw-ignore-regex": false,
  "attr-bans": [
    "align",
    "background",
    "bgcolor",
    "border",
    "frameborder",
    "longdesc",
    "marginwidth",
    "marginheight",
    "scrolling",
    "style",
    "width",
  ],
  "indent-delta": false,
  "indent-style": "spaces",
  "indent-width": 2,
  "indent-width-cont": false,
  "spec-char-escape": true,
  "text-ignore-regex": false,
  "tag-bans": ["style", "b"],
  "tag-close": true,
  "tag-name-lowercase": true,
  "tag-name-match": true,
  "tag-self-close": false,
  "doctype-first": false,
  "doctype-html5": false,
  "attr-name-style": "dash",
  "attr-name-ignore-regex": false,
  "attr-no-dup": true,
  "attr-no-unsafe-char": true,
  "attr-order": false,
  "attr-quote-style": "double",
  "attr-req-value": false,
  "attr-new-line": false,
  "attr-validate": true,
  "id-no-dup": true,
  "id-class-no-ad": false,
  "id-class-style": false, // "lowercase", "underscore", "dash", "camel", "bem"
  "class-no-dup": true,
  "class-style": false,
  "id-class-ignore-regex": false,
  "img-req-alt": true,
  "img-req-src": true,
  "html-valid-content-model": true,
  "head-valid-content-model": true,
  "href-style": false,
  "link-req-noopener": true,
  "label-req-for": false,
  "line-end-style": "lf",
  "line-no-trailing-whitespace": true,
  "line-max-len": false,
  "line-max-len-ignore-regex": false,
  "head-req-title": true,
  "title-no-dup": true,
  "title-max-len": 60,
  "html-req-lang": false,
  "lang-style": "case",
  "fig-req-figcaption": false,
  "focusable-tabindex-style": false,
  "input-radio-req-name": true,
  "input-req-label": false,
  "table-req-caption": false,
  "table-req-header": false,
  "tag-req-attr": false,
};
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nebulab/erb-linter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
