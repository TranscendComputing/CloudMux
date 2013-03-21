require 'service_spec_helper'

describe ErrorRepresenter do

  before :each do
    @message = Error.new
  end

  describe "#to_json" do
    it "should export to json" do
      msg = "This is my message"
      @message.message = msg
      @message.extend(ErrorRepresenter)
      result = @message.to_json
      result.should eq("{\"error\":{\"message\":\"#{msg}\"}}")
    end

    it "should export validation_errors to json" do
      msg = "This is my message"
      @message.message = msg
      @message.validation_errors = { :foo=>"bar" }
      @message.extend(ErrorRepresenter)
      result = @message.to_json
      result.should eq("{\"error\":{\"message\":\"#{msg}\",\"validation_errors\":{\"foo\":\"bar\"}}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      msg = "This is my message"
      json = "{\"error\":{\"message\":\"#{msg}\"}}"
      @message.extend(ErrorRepresenter)
      @message.from_json(json)
      @message.message.should eq(msg)
    end
  end
end
