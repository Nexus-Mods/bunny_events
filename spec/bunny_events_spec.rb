require 'bunny-mock'

RSpec.describe BunnyEvents do

  let(:mock_bunny) {}

  it "should not be connected by default" do
    expect(BunnyEvents.connected?).to be false
  end

  describe "initialising BunnyEvents with mock bunny connection" do

    it "should fail with no valid bunny connection" do
      expect{BunnyEvents.init nil}.to raise_error Exceptions::InvalidBunnyConnection
      expect{BunnyEvents.init Object.new}.to raise_error Exceptions::InvalidBunnyConnection
    end

    it "should work if a valid bunny connection is passed" do
      BunnyEvents.init BunnyMock.new.start

      expect(BunnyEvents.connected?).to be(true)
    end

  end

  describe "publishing an event" do
    before(:each) do
      BunnyEvents.init BunnyMock.new.start
    end

    let(:valid_event) { DummyMessage.new "test" }

    it "should fail if a non-BunnyEvent was passed" do
      expect{BunnyEvents.publish nil}.to raise_error Exceptions::InvalidBunnyEvent
    end

    it "should pass and create queues and exchanges if a valid BunnyEvent was passed" do
      expect{BunnyEvents.publish valid_event}.not_to raise_error
      expect(BunnyEvents.bunny_connection.exchange_exists?('test_exchange')).to be_truthy
      expect(BunnyEvents.bunny_connection.queue_exists?('queue_1')).to be_truthy
      expect(BunnyEvents.bunny_connection.queue_exists?('queue_2')).to be_truthy
    end
  end

end
