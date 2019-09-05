RSpec.describe BunnyEvent do
  it "has a version number" do
    expect(BunnyEvent::VERSION).not_to be nil
  end

  it "does not raise an error of any kind" do
    expect{ DummyEvent.new({
         msg: "This is a test"
     })}.not_to raise_error
  end

  describe "creating a new message queue event" do

    let(:event){
      DummyEvent.new("hello")
    }

    it "sets the message correctly" do
      expect(event.message).to eq("My test message is hello")
    end

    it "sets the amqp options correctly" do
      expect(event.class.options).to eq(:routing_key=>"test_queue", :exchange => "test_exchange", :exchange=>"test_exchange", :exchange_opts=>{:durable=>true, :type=>:direct}, :queues=>{:test_queue=>{:opts=>{:durable=>true}, :routing_key=>""}})
    end
  end

end
