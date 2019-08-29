RSpec.describe MessageQueueEvent do
  it "has a version number" do
    expect(MessageQueueEvent::VERSION).not_to be nil
  end

  it "does not raise an error of any kind" do
    expect{ DummyMessage.new({
         msg: "This is a test"
     })}.not_to raise_error
  end

  describe "creating a new message queue event" do

    let(:event){
      DummyMessage.new("hello")
    }

    it "sets the message correctly" do
      expect(event.message).to eq("My test message is hello")
    end

    it "sets the amqp options correctly" do
      expect(event.class.options).to eq(:exchange => "test_exchange", :exchange_type => :fanout)
    end
  end

end
