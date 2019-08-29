class DummyMessage
  include MessageQueueEvent

  event_options :exchange => "test_exchange",
                :exchange_type => :fanout

  def initialize(msg)
    @message = "My test message is #{msg}"
  end

end
