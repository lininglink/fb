# Fb

This is a Ruby gem can call Facebook API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add fb --github=lininglink/fb
```

This gem is not on [rubygems.org](https://rubygems.org). Do not run `gem install fb` or `bundle add fb` (there is a name of this gem for a different gem)

## Usage

`Fb::User` takes access_token.
```rb
user = Fb::User.new(access_token: "EAAH8MdSXN5...")
user.pages
# will output a list of `Fb::Page`
user.businesses
# will output a list of `Fb::Business`
```

There are `owned_pages` and `client_pages` on each business.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lininglink/fb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lininglink/fb/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
