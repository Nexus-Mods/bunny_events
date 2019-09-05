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

  describe "publishing an event" do

    before(:each) do
      bunny_events.init BunnyMock.new.start
    end

    let(:valid_event) { DummyEvent.new "test" }
    let(:fanout_event) {DummyFanoutEvent.new "test"}
    let(:always_create_event) {AlwaysCreateDummyEvent.new "test"}
    let(:default_exchange_event) {DefaultExchangeDummyEvent.new "test"}

    it "should fail if a non-BunnyEvent was passed" do
      expect{bunny_events.publish nil}.to raise_error Exceptions::InvalidBunnyEvent
    end

    it "should pass and create queues and exchanges if a valid BunnyEvent was passed" do
      expect{bunny_events.publish valid_event}.not_to raise_error
      expect(bunny_events.bunny_connection.exchange_exists?('test_exchange')).to be_truthy
      expect(bunny_events.bunny_connection.queue_exists?('test_queue')).to be_truthy
    end

    it "should only create queues on the first pass by default" do

      bunny_mock = BunnyMock.new.start
      bunny_events.init bunny_mock

      expect{bunny_events.publish valid_event}.not_to raise_error
      expect(bunny_mock.exchange_exists?('test_exchange')).to be_truthy
      expect(bunny_mock.queue_exists?('test_queue')).to be_truthy

      channel = bunny_mock.create_channel
      q = channel.queue 'test_queue'


      expect(bunny_mock.queue_exists?('test_queue')).to be_truthy
      expect(q.message_count).to eq(1)
      # delete exchange to check creation isn't performed a second time


      x = channel.exchange 'test_exchange'
      x.delete

      expect(bunny_mock.exchange_exists?('test_exchange')).to be_falsey

      # We are expecting an error, as we just manually deleted the exchange, but the event system should only
      # create the queues and exchanges once by default.
      expect{bunny_events.publish(valid_event)}.to raise_error Exceptions::InvalidExchange

    end

    it "shouldn't automatically bind the queues to the default exchange" do
      expect{bunny_events.publish default_exchange_event}.not_to raise_error
      expect(bunny_events.bunny_connection.exchange_exists?('')).to be_truthy
      expect(bunny_events.bunny_connection.queue_exists?('default_exchange_queue')).to be_truthy
    end

  end
end
