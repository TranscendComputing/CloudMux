require 'cfdoc_spec_helper'

describe CFDoc::Model::Stack do
  before :each do
    @stack = CFDoc::Model::Stack.new
  end

  describe "#initialize" do
    it "should initialize the templates attr" do
      @stack.templates.should_not eq(nil)
      @stack.templates.empty?.should eq(true)
    end
  end

  describe "#<<" do
    it "should accept StackTemplate models" do
      template = CFDoc::Model::StackTemplate.new
      @stack << template
      @stack.templates.length.should eq(1)
      @stack << template
      @stack.templates.length.should eq(2)
    end

    it "should fail for other classes" do
      expect { @stack << "This is a string" }.to raise_error
    end
  end

end
