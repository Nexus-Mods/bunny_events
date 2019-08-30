require 'bunny_event'

class DummyEvent
  include BunnyEvent

  event_options :exchange => "test_exchange",
                :exchange_opts => {
                    :durable => true,
                    :type => :direct
                },
                :queues =>
                    {
                        :test_queue => {
                            :opts => {
                                :durable => true
                            },
                            :routing_key => ""
                        }
                    }

  def initialize(msg)
    @message = "My test message is #{msg}"
  end

end

class DummyFanoutEvent
  include BunnyEvent

  event_options :exchange => "fanout_exchange",
                :exchange_opts => {
                    :durable => true,
                    :type => :fanout
                },
                :queues =>
                    {
                        :test_queue_1 => {
                            :opts => {
                                :durable => true
                            },
                            :routing_key => ""
                        },
                        :test_queue_2 => {
                            :opts => {
                                :durable => true
                            },
                            :routing_key => ""
                        }
                    }

  def initialize(msg)
    @message = "My test message is #{msg}"
  end

end
