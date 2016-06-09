# FixedWidthFileParser

FixedWidthFileParser is used to parse fixed width files. Crazy right?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixed_width_file_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fixed_width_file_parser

## Usage

In order to parse a fixed width file, you need to define the fields (and their positions) as well as the filepath, and then pass those to a block that will yield the data for each row.

e.g.

```ruby
filepath = 'path/to/file'
fields = [
  { name: 'first_name', position: 0..10 },
  { name: 'middle_initial', position: 11 },
  { name: 'last_name', position: 12..25 }
]

FixedWidthFileParser.parse(filepath, fields) do |row|
  puts row[:first_name]
  puts row[:middle_initial]
  puts row[:last_name]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fixed_width_file_parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
