require 'bunny_event'

class DummyMessage
  include BunnyEvent

  event_options :exchange => "test_exchange",
                :exchange_type => :fanout,
                :bindings => {
                    :queue_1 => {
                        :routing_key => ""
                    },
                    :queue_2 => {
                        :routing_key => ""
                    },
                }

  def initialize(msg)
    @message = "My test message is #{msg}"
  end

end
