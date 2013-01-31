require 'service_spec_helper'

describe ImportTemplate do
  before :each do
    @import = ImportTemplate.new
  end

  describe "#initialize" do
    it "should initialize properly" do
      @import.should_not eq(nil)
    end
  end
end
