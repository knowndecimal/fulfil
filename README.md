[![Tests](https://github.com/knowndecimal/fulfil/actions/workflows/tests.yml/badge.svg)](https://github.com/knowndecimal/fulfil/actions/workflows/tests.yml)

# Fulfil.io Rubygem

A Ruby library for the [Fulfil.io](https://fulfil.io) API.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'fulfil-io'
```

And then execute:

```shell
  $ bundle install
```

Or install it yourself as:

```shell
  $ gem install fulfil-io
```

## Usage

Environment variables:

- **FULFIL_SUBDOMAIN:** - always required to use the gem.
- **FULFIL_OAUTH_TOKEN:** required for oauth bearer authentication
- **FULFIL_API_KEY:** required for authentication via the `X-API-KEY` request header

> **Note:** When `FULFIL_OAUTH_TOKEN` is present, the `FULFIL_API_KEY` will be ignored. So,
if oauth doesn't work, returning an Unauthorized error, to use the
`FULFIL_API_KEY`, the `FULFIL_OAUTH_TOKEN` shouldn't be specified.

```ruby
fulfil = Fulfil::Client.new # or, to enable request debugging, Fulfil::Client.new(debug: true)

sale_model = Fulfil::Model.new(
  client: fulfil,
  model_name: 'sale.sale'
)

sales = sale_model.search(
  domain: [['id', '=', 10]],
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

## Rate limits

Fulfil's API applies rate limits to the API requests that it receives. Every request is subject to throttling under the general limits. In addition, there are resource-based rate limits and throttles.

This gem exposes an API for checking your current rate limits (note: the gem only knows about the rate limit after a request to Fulfil's API has been made).

Whenever you reached the rate limit, the `Fulfil::RateLimitExceeded` exception is being raised. You can use the information on the `Fulfil.rate_limit` to find out what to do next.

```ruby
$ Fulfil.rate_limit.requests_left?
=> true

# The maximum number of requests you're permitted to make per second.
$ Fulfil.rate_limit.limit
=> 9

# The time at which the current rate limit window resets in UTC epoch seconds.
$ Fulfil.rate_limit.resets_at
=> #<DateTime: 2022-01-21T16:36:01-04:00 />
```

### Automatic retry API call after rate limit hit

Automatic retries are supported whenever the rate limit is reached. However, it's not enabled by default. To enable it, set the `retry_on_rate_limit` to `true`. By default, the request will be retried in 1 second.

```ruby
# config/initializers/fulfil.rb

Fulfil.configure do |config|
  config.retry_on_rate_limit = true # Defaults to false
  config.retry_on_rate_limit_wait = 0.25 # Defaults to 1 (second)
end
```

### Monitor rate limit hits

Through the configurable `rate_limit_notification_handler` one can monitor the rate limit hits to the APM tool of choice.

```ruby
# config/initializers/fulfil.rb

Fulfil.configure do |config|
  config.rate_limit_notification_handler = proc {
    FakeAPM.increment_counter('fulfil.rate_limit_exceeded')
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Release a new version

We're following semver for the release process of this gem. Make sure to apply the correct semver version for a new release.

To release a new version, run the `bin/release x.x.x`. That's it.

> **NOTE:** You don't have to add a v to the version you want to release. The release script will handle that for you.

### Testing

For non-client tests, create the test class or case.

For client tests, you'll need to add a couple steps. If running against a real
backend, you'll need to provide a couple of environment variables:
`FULFIL_SUBDOMAIN` and `FULFIL_OAUTH_TOKEN`. Additionally, pass `debug: true` to the
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
