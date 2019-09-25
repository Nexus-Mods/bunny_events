require 'bunny'

class BunnyEvents
  attr_accessor :channels, :bunny_connection

  # Keeps track of which events have been intiailized by this BunnyEvents worker. Used to ensure that the queue and
  # exchange creation is only performed once.
  attr_accessor :initialized_events

  @@defaults = {
    exchange: '',
    exchange_type: :direct,
    routing_key: 'message_queue_event'
  }

  # Initialise the BunnyEvents system by accepting a bunny connection.
  #
  # Example:
  #
  # NOTE: This can also accept bunnymock for testing
  # bunny_events = BunnyEvents.new
  # bunny_events.init BunnyMock.new.start
  #
  def init(bunny_connection)
    # Ensure the bunny_connection is valid
    if bunny_connection.nil? || !bunny_connection.respond_to?(:connected?)
      raise Exceptions::InvalidBunnyConnection
    end

    @channels = {}

    @initialized_exchanges = {}

    @bunny_connection = bunny_connection
  end

  def connected?
    @bunny_connection&.connected? || false
  end

  # Public message. message should be an instance of BaseMessage (or a class with BaseMessage included)
  def publish(message, routing_key = nil)
    unless message.class.included_modules.include?(BunnyEvent)
      raise Exceptions::InvalidBunnyEvent
    end

    raise Exceptions::InvalidBunnyConnection unless connected?

    # get the options defined by the message queue event class
    opts = @@defaults.merge message.class.options

    # Use the class name to determine which channel to use
    unless @channels.key?(message.class.name)
      @channels[message.class.name] = @bunny_connection.create_channel
    end

    channel = @channels[message.class.name]

    #  Ensure that the exchange, queue and binding creation is only performed once
    if !@initialized_exchanges.key?(message.class.name) || opts[:always_create_when_publishing]
      # If the event was sent with an exchange name, create and submit this to the exchange, otherwise, just use the default exchange
      x = if !opts[:exchange].nil? && !opts[:exchange].empty?
            channel.exchange(opts[:exchange], opts[:exchange_opts] || {})
          else
            channel.default_exchange
          end
      # if the event was sent with queue definitions, ensure to create the bindings
      handle_queue_definitions channel, x, opts[:queues] unless opts[:queues].nil?

      # ensure this event's creation params are not processed again
      @initialized_exchanges[message.class.name] ||= x
    end

    x ||= @initialized_exchanges[message.class.name]

    # ensure exchange is not null
    if x.nil? || !@bunny_connection.exchange_exists?(opts[:exchange])
      raise Exceptions::InvalidExchange
    end

    # publish message along with the optional routing key
    x.publish message.message, routing_key: routing_key || opts[:routing_key]
  end

  private

  def handle_queue_definitions(channel, exchange, queues)
    queues.each do |q, opts|
      # Create this queue and bind, if the binding options are present
      queue = channel.queue q.to_s, opts[:opts] || {}

      # if ignore bind isn't set, set to nil
      ignore_bind = opts[:ignore_bind] || false

      # if we aren't ignoring the binding for this queue, check if it's already bound. We also shouldn't bind directly
      # to the default queue
      if !ignore_bind && exchange.name != ''
        queue.bind exchange, key: opts[:routing_key] || ''
      end
    end
  end
end
