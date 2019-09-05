require 'bunny_events'

# Module that can be included into a ruby class to create a definition of a BunnyEvent. These events can then be published
# via the BunnyEvents system.
module BunnyEvent
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

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end
end

module Exceptions
  class InvalidBunnyConnection < StandardError; end
  class InvalidBunnyEvent < StandardError; end
  class InvalidExchange < StandardError; end
end
