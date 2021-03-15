# Fulfil.io Rubygem

[![CircleCI](https://circleci.com/gh/knowndecimal/fulfil.svg?style=svg&circle-token=da80ea6500af15b3a795a3913efe35742bab94c1)](https://circleci.com/gh/knowndecimal/fulfil)

[Fulfil.io](https://fulfil.io)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fulfil-io', require: 'fulfil'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fulfil-io

## Usage

Environment variables:

- FULFIL_SUBDOMAIN - required to be set.
- FULFIL_TOKEN - required for oauth bearer authentication
- FULFIL_API_KEY - required for authentication via the X-API-KEY request header

**Note:** When FULFIL_TOKEN is present, the FULFIL_API_KEY will be ignored. So,
if oauth doesn't work, returning an Unauthorized error, to use the
FULFIL_API_KEY, the FULFIL_TOKEN shouldn't be specified.

```ruby
require 'fulfil' # this is necessary only in case of running without bundler

fulfil = Fulfil::Client.new # or, to enable request debugging, Fulfil::Client.new(debug: true)

sale_model = Fulfil::Model.new(
  client: fulfil,
  model_name: 'sale.sale'
)

sales = sale_model.search(
  domain: [['id', '=', [10]]],
  fields: ['id', 'rec_name', 'lines']
)

# -- OR --

sale_model.query(id: 100)
sale_model.query(ids: 100..150)

sale_model.fetch_associated(
  models: sales,
  association_name: 'sale.line',
  source_key: 'lines',
  fields: %w[id unit_price]
)

pp sales

# [{"id"=>10,
#   "lines"=>
#    [{"id"=>311, "unit_price"=>34.95},
#     {"id"=>313, "unit_price"=>0.0}],
#   "rec_name"=>""}]
```

### Count

```ruby
client = Fulfil::Client.new
model = Fulfil::Model.new(client: client, model_name: 'stock.shipment.out')
model.count(domain: [['shipping_batch.state', '=', 'open']])

# Returns 7440
```

### Writing

As of v0.3.0, we've added very basic support for creates and updates via
`Fulfil::Client#post` and `Fulfil::Client#put`.

*Create Example*

```ruby
fulfil = Fulfil::Client.new

sale_model = Fulfil::Model.new(client: fulfil, model_name: 'sale.sale')

sale = {
  # Full Sale attributes here
}

fulfil.post(model: sale_model, body: sale)
```

*Update Example*

```ruby
fulfil = Fulfil::Client.new

sale_model = Fulfil::Model.new(client: fulfil, model_name: 'sale.sale')
sale = sale_model.find(id: 1234)

sale['channel'] = 4

fulfil.put(model: sale_model, body: sale)
```
### Interactive Reports

As of v0.4.6, interactive report support exists in a basic form.
You're able to execute reports with basic params. Responses are
transformed to JSON structures.

```ruby
fulfil = Fulfil::Client.new

report = Fulfil::Report.new(client: fulfil, report_name: 'account.tax.summary.ireport')

report.execute(start_date: Date.new(2020, 12, 1), end_date: Date.new(2020, 12, 31))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Testing

For non-client tests, create the test class or case.

For client tests, you'll need to add a couple steps. If running against a real
backend, you'll need to provide a couple of environment variables:
`FULFIL_SUBDOMAIN` and `FULFIL_TOKEN`. Additionally, pass `debug: true` to the
client instance in the test. This will output the response body. Webmock will
probably complain that real requests aren't allowed at this point, offering you
the stub. We don't need most of that.

We will need to capture the response body as JSON and store it in the
`test/fixtures` directory. Formatted for readability, please. You'll also need
to make note of the path and body of the request. Once you have that, you can
generate your stub.

To stub a request, use (or create) the helper method based on the verb. For
example, to stub a `GET` request, use `stub_fulfil_get`. Here's an example:

```ruby
def test_find_one
  stub_fulfil_get('sale.sale/213112', 'sale_sale')

  client = Fulfil::Client.new
  response = client.find_one(model: 'sale.sale', id: 213_112)

  assert_equal 213_112, response['id']
end
```

`stub_fulfil_get` takes two arguments: the URL path (after `/api/v2/model/`)
and the fixture file name to be returned.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/knowndecimal/fulfil. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fulfil project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/[USERNAME]/fulfil/blob/master/CODE_OF_CONDUCT.md).
