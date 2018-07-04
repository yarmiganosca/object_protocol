require 'object_protocol'

RSpec.describe ObjectProtocol::VERSION do
  it "has a version number" do
    expect(ObjectProtocol::VERSION).not_to be nil
  end
end
