# HPFeeds

This gem should be used to make easy to interact (publish, subscribe) with a [HPFeeds broker](https://redmine.honeynet.org/projects/hpfeeds/wiki).

## Installation

Add this line to your application's Gemfile:

    gem 'hpfeeds'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hpfeeds

## Usage

Here is a basic example:

```ruby
require "hpfeeds"

def on_data(name, chan, payload)
  puts "[%s] %s: %s" % [ chan, name, payload ]
  # just an example here...
  @hp.publish('channel', 'message')
end

def on_error(data)
  STDERR.puts "ERROR: " + data.inspect
end

begin
  @hp = HPFeeds::Client.new ({
    host:   hpfeeds_server_name_here,
    port:   hpfeeds_port_number_here,  # default is 10000
    ident:  'XXXXXX',
    secret: '123456'
  })
  channels = %w[ chan1 chan2 chanN ]
  @hp.subscribe(*channels) { |name, chan, payload| on_data(name, chan, payload) }
  @hp.run(method(:on_error))

rescue => e
  puts "Exception: #{e}"
ensure
  @hp.close if @hp
end
```
### HPFeeds messages handler
It's also possibile to set separate handlers for messages from different channels, as follows:
```ruby
@hp.subscribe(chan1, chan2) do
  puts "Received something"
end

@hp.subscribe(chan3, chan4, chan5) do |name, chan|
  puts "Received something on #{chan}, from #{name}"
end

@hp.subscribe(chan6, chan7) { |name, chan, payload| custom_method(name, chan, payload) }
```
### HPFeeds errors handler
The argument in
```ruby
@hp.run(method(:on_error))
```
is an handler for HPFeeds error messages (i.e. `'accessfail'` or `'authfail'`).
It's optional: if you don't provide any handler, an exception will be raised (`HPFeeds::ErrorMessage`) in case of error messages.

### Logging
It's possibile to specify a path for log file (default is stdout) and a log level, as follows
```ruby
  @hp = HPFeeds::Client.new ({
    host:   hpfeeds_server_name_here,
    port:   hpfeeds_port_number_here,  # default is 10000
    ident:  'XXXXXX',
    secret: '123456',
    log_to: path_to_log_file,          # default is STDOUT
    log_level: :debug                  # default is info
  })
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
