require 'bunny'

class BunnyEvents

  attr_accessor :channels, :bunny_connection

  @@defaults = {
      :exchange => "",
      :exchange_type => :direct,
      :routing_key => "message_queue_event"
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
      raise Exceptions::InvalidBunnyConnection.new
    end

    @channels = {}

    @bunny_connection = bunny_connection

  end

  def connected?
    @bunny_connection&.connected? || false
  end

  # Public message. message should be an instance of BaseMessage (or a class with BaseMessage included)
  def publish(message)

    unless message.class.included_modules.include?(BunnyEvent)
      raise Exceptions::InvalidBunnyEvent.new
    end

    unless connected?
      throw "Not connected"
    end

    # get the options defined by the message queue event class
    opts = @@defaults.merge message.class.options

    # Use the class name to determine which channel to use
    unless @channels.key?(message.class.name)
      @channels[message.class.name] = @bunny_connection.create_channel
    end

    channel = @channels[message.class.name]

    # If the event was sent with an exchange name, create and submit this to the exchange, otherwise, just use the default exchange
    if !opts[:exchange].nil? && !opts[:exchange].empty?
      x = channel.exchange(opts[:exchange], opts[:exchange_opts] || {})
    else
      x = channel.default_exchange
    end

    # if the event was sent with queue definitions, ensure to create the bindings
    if !opts[:queues].nil?
      handle_queue_definitions channel, x, opts[:queues]
    end

    x.publish message.message, :routing_key => opts[:routing_key]

    end

  private
    def handle_queue_definitions (channel, exchange, queues)
      queues.each do |q, opts|
        # Create this queue and bind, if the binding options are present
        queue = channel.queue q.to_s, opts[:opts] || {}
        queue.bind exchange, :key => opts[:routing_key] || ""
      end
    end
end