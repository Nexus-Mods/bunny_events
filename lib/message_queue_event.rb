require 'amqp_connector'

module MessageQueueEvent

  attr_accessor :message

  module ClassMethods

    # Class method to allow the setting of event options in the message definitions
    def event_options(options)
      @options = options
    end

    # Class method for retreiving the data via the `MyMessage.class.options`
    def options
      @options
    end
  end

  # Instance method for publishing a message to the rabbit service
  def publish!
    AMQPConnector.publish self
  end

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end
end