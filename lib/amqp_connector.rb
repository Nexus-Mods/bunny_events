require 'bunny'

class AMQPConnector

  def initialize
    establish_connection
  end

  class << self
    attr_accessor :active_connection, :channels, :amqp_connection
  end

  @@defaults = {
      :exchange => "",
      :exchange_type => :direct,
      :routing_key => "message_queue_event"
  }

  def self.establish_connection
    @active_connection = Bunny.new(@amqp_connection)
    @active_connection.start

    # Make sure the queue binding also exists
    @active_connection
  end

  def self.connection
    return active_connection if connected?
    establish_connection

    active_connection
  end

  def self.connected?
    active_connection&.connected?
  end

  # Public message. message should be an instance of BaseMessage (or a class with BaseMessage included)
  def self.publish(message)

    unless connected?
      establish_connection
    end

    # If there are no channels, or this message's key does not appear in our channel list, create a new channel
    if @channels.nil?
      @channels = {}
    end

    # get the options defined by the message queue event class
    opts = @@defaults.merge message.class.options

    # Use the class name to determine which channel to use
    unless @channels.key?(message.class.name)
      @channels[message.class.name] = @active_connection.create_channel
    end

    channel = @channels[message.class.name]

    # If our message was sent with an exchange name, create and submit this to the exchange, otherwise, just use the default exchange
    if !opts[:exchange_name].nil? && !opts[:exchange_name].empty?
      x = Bunny::Exchange.new(channel, opts[:exchange_type], opts[:exchange])
    else
      x = Bunny::Exchange.default(channel)
    end

    x.publish message.message, :routing_key => opts[:routing_key]

  end
end