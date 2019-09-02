# Bunny Events

[![Gem Version](https://badge.fury.io/rb/bunny_events.svg)](https://badge.fury.io/rb/bunny_events)

A simple wrapper gem to aid with producing events to a message queue, using Bunny, in a standardized and uniform way across multiple microservices.

Rather than usin Bunny directly, this gem allows an application to define "Event Definitions" which can be defined and published
in a modular way. This ensures that when you are producing a message, your application logic shouldn't care about how the
message is produced (E.g. your controller shouldn't care or know anything about what exchange to publish a message to, only the BunnyEvent 
that has been defined cares)

Current Features and limitation:

- Allows a bunny connection to initialise the system
- Allows the definition of abstract events to be used application-wide
- Customization of exchange and queue options when producing an event

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bunny_events'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bunny_events

## Usage

### Defining an event

To produce an event to the message queue, we must first define an event. In `app/events/my_test_event.rb`

```ruby
class MyTestEvent
  include BunnyEvent

  # define the event options for queueing this event. Each event type can have different options.
  event_options :exchange => "test_exchange",
                :exchange_type => :fanout

  # We can define what the message payload looks like here.
  def initialize(msg)
    @message = "My test message is #{msg}"
  end
end

```

### Changing the message payload

We can change the payload in the `initialize` method, allowing us complete control over what data is used to create the message.

```ruby
  def initialize(user, page)
    @message = {
        :user_id => user.id,
        :user_name => user.name,
        :page => page.url,
        :timestamp => Time.now.to_i
    }.to_json
  end
```

This ensures complete control over how your application produces a message, enabling your application to utilise JSON, AVRO, or just plain old strings.

### Publish event

Publishing the event requires the use of the BunnyEvents class

```ruby
  # Create event, passing in whatever data is needed
  event = MyTestEvent.new "This is a test event"
  
  # Use the BunnyEvents system to publish this event
  BunnyEvents.publish event
```

### Full example with initialisation

```ruby

# This is done once as part of the configuration step, usually in a rails initializer, or at the start of your application
BunnyEvents.init Bunny.new("amqp://rabbitmq:rabbitmq@rabbit1:5672").start
   
# Event definitions are defined in classes, in rails, we generally use app/messages
class MyTestEvent
 include BunnyEvent

# define the event options for queueing this event. Each event type can have different options.
event_options :exchange => "test_exchange",
            :exchange_opts => {
                :type => :fanout
            },
            :queues =>
                {
                    :some_queue => {
                        :opts => {
                          :durable => true
                        },
                        :routing_key => ""
                    }
                }

 # We can define what the message payload looks like here.
 def initialize(msg)
   @message = "My test message is #{msg}"
 end
end

# When we want to create a new instance of an event, we create and publish the object
event = MyTestEvent.new "test"
BunnyEvents.publish event
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Nexus-Mods/message_queue_event.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
