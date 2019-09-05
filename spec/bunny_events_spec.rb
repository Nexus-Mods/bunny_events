require 'bunny-mock'

RSpec.describe BunnyEvents do

  let(:bunny_events) {  BunnyEvents.new }

  it "should not be connected by default" do
    expect(bunny_events.connected?).to be false
  end

  describe "initialising BunnyEvents with mock bunny connection" do

    it "should fail with no valid bunny connection" do
      expect{bunny_events.init nil}.to raise_error Exceptions::InvalidBunnyConnection
      expect{bunny_events.init Object.new}.to raise_error Exceptions::InvalidBunnyConnection
    end

    it "should work if a valid bunny connection is passed" do
      bunny_events.init BunnyMock.new.start

      expect(bunny_events.connected?).to be(true)
    end
  end

  before(:each) do
    @bunny_mock = BunnyMock.new.start
    @bunny_events = BunnyEvents.new
    @bunny_events.init @bunny_mock
    @channel = @bunny_mock.channel
  end

  it "should fail if a non-BunnyEvent was passed" do
    expect{@bunny_events.publish nil}.to raise_error Exceptions::InvalidBunnyEvent
  end

  describe "publishing a standard event" do

    before(:each) do
      expect{@bunny_events.publish DummyEvent.new "test"}.not_to raise_error
    end

    it "should have created exchange" do
      expect(@bunny_mock.exchange_exists?('test_exchange')).to be_truthy
    end

    it "should have created queue" do
      expect(@bunny_mock.queue_exists?('test_queue')).to be_truthy
    end

    it "should bind the queue to the exchange" do
      exchange = @channel.exchange 'test_exchange'
      queue = @channel.queue 'test_queue'

      expect(queue.bound_to? exchange).to eq true
    end

    it "should increase message count" do
      queue = @channel.queue 'test_queue'
      expect(queue.message_count).to eq 1
    end

    it "should increase message count after multiple events" do
      expect{@bunny_events.publish DummyEvent.new "test"}.not_to raise_error
      expect{@bunny_events.publish DummyEvent.new "test"}.not_to raise_error

      # check that 3 messages (one from the before :each) exist
      queue = @channel.queue 'test_queue'
      expect(queue.message_count).to eq 3
    end

    it "should ensure the queue/exchange creation is only performed once" do

      # delete exchange to ensure creation tasks are not performed again
      exchange = @channel.exchange 'test_exchange'
      exchange.delete

      expect{@bunny_events.publish DummyEvent.new "test"}.to raise_error Exceptions::InvalidExchange
    end

  end

  describe "publishing an :always_create_when_publishing event" do

    it "should create the exchange/queue every time a message is published" do

      expect{@bunny_events.publish AlwaysCreateDummyEvent.new "test"}.not_to raise_error

      # delete exchange to ensure creation tasks are not performed again
      exchange = @channel.exchange 'test_exchange'
      exchange.delete

      expect{@bunny_events.publish AlwaysCreateDummyEvent.new "test"}.not_to raise_error
    end

    it "should increase message count after multiple messages" do
      expect{@bunny_events.publish AlwaysCreateDummyEvent.new "event1"}.not_to raise_error
      expect{@bunny_events.publish AlwaysCreateDummyEvent.new "event2"}.not_to raise_error

      queue = @channel.queue 'test_queue'
      expect(queue.message_count).to eq 2
    end
  end

  describe "publishing to the default exchange" do

    before(:each) do
      expect{@bunny_events.publish DefaultExchangeDummyEvent.new "test"}.not_to raise_error
    end

    it "should have created queue" do
      expect(@bunny_events.bunny_connection.queue_exists?('test_queue')).to be_truthy
    end

    it "should not bind the queue to the exchange" do
      exchange = @channel.exchange ''
      queue = @channel.queue 'test_queue'

      expect(queue.bound_to? exchange).to eq false
    end

  end


end
