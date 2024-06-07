# SVG

An SVG generation wrapper for pure Ruby!

This gem simply allows your to build SVGs with Ruby syntax. The objects accessible are largely straight from SVGs and should be fairly intuitive, allowing you to build an SVG with Ruby syntax and logic in no time!

You can even extend the SVG class to register your own svg types to give you shortcuts to generate your own components!

Basic example:
```ruby
SVG.new(:svg) do |svg|
  svg.minx = -5
  svg.miny = -105
  svg.width = 110
  svg.height = 110

  svg.circle(5, -5, 5)
end
```


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ruby-svg

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ruby-svg

## Usage



## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Rockster160/ruby-svg. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Rockster160/ruby-svg/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SVG project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Rockster160/ruby-svg/blob/master/CODE_OF_CONDUCT.md).
