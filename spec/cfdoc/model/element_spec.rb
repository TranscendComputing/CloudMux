require 'cfdoc_spec_helper'

describe CFDoc::Model::Element do
  before :each do
    @name = "Element"
    @fields = { "field1"=>"value1", "field2"=>"value2"}
    @element = CFDoc::Model::Element.new(@name)
    @element.fields = @fields
  end

  describe "#initialize" do
    it "should initialize name" do
      @element.name.should eq(@name)
    end

    it "should initialize fields" do
      @element.fields.should_not eq(nil)
      @element.fields.length.should eq(@fields.length)
    end

    it "should not fail if initialized with a nil fields value" do
      @element = CFDoc::Model::Element.new("")
      @element.fields.should_not eq(nil)
      @element.fields.empty?.should eq(true)
    end
  end

  describe "#fields" do
    it "should set the field values" do
      @element = CFDoc::Model::Element.new("")
      @element.fields.empty?.should eq(true)
      @element.fields = @fields
      @element.fields.should_not eq(nil)
      @element.fields.length.should eq(@fields.length)
    end
  end

  describe "#<<" do
    it "should accept Element models and subclasses" do
      element = CFDoc::Model::Element.new("element")
      @element << element
      @element.children.length.should eq(1)

      parameter = CFDoc::Model::Parameter.new("param")
      @element << parameter
      @element.children.length.should eq(2)
    end

    it "should fail for other classes" do
      expect { @element << "This is a string" }.to raise_error
    end
  end

  describe "#child" do
    it "should find a child by name" do
      element = CFDoc::Model::Element.new("element")
      @element << element
      parameter = CFDoc::Model::Parameter.new("param")
      @element << parameter
      @element.child(element.name).should eq(element)
      @element.child(parameter.name).should eq(parameter)
    end

    it "should not find a child by a name that doesn't exist" do
      @element.child("fake").should eq(nil)
    end

    it "should not find a child by a nil name" do
      @element.child(nil).should eq(nil)
    end
  end

  describe "#[]" do
    it "should access a field by name" do
      @element["field1"].should eq("value1")
    end
  end

  describe "#key" do
    it "should return nil if the name is nil" do
      @element = CFDoc::Model::Element.new(nil)
      @element.key.should eq(nil)
    end
  end
end
