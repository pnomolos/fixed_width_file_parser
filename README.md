# FixedWidthFileParser
[![Build Status](https://travis-ci.org/elevatorup/fixed_width_file_parser.svg?branch=master)](https://travis-ci.org/elevatorup/fixed_width_file_parser)
[![Code Climate](https://codeclimate.com/github/elevatorup/fixed_width_file_parser/badges/gpa.svg)](https://codeclimate.com/github/elevatorup/fixed_width_file_parser)

FixedWidthFileParser is used to parse fixed width files. Crazy right?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixed_width_file_parser'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install fixed_width_file_parser
```

## Usage

In order to parse a fixed width file, you need to define the fields (and their positions) as well as the filepath, and then pass those to a block that will yield the data for each row.

```ruby
filepath = 'path/to/file.txt'
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

### Tips
If you need to parse a fixed width file that has the last field set as a variable width field, you can set the position similar to `position: 12..-1`. Setting the end of the range as `-1` will read to the end of that line.

```ruby
filepath = 'path/to/file.txt'
fields = [
  { name: 'first_name', position: 0..10 },
  { name: 'middle_initial', position: 11 },
  { name: 'last_name', position: 12..-1 }
]
```

## Options
|Name|Default Value|Description|
|---|---|---|
|force_utf8_encoding|true|Force UTF-8 encoding on lines being parsed. This alleviates `invalid byte sequence in UTF-8` errors thrown when trying to split a string with invalid UTF characters. For more information, view this [article](https://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences).|


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/elevatorup/fixed_width_file_parser/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request
