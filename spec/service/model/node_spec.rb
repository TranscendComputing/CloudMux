require 'service_spec_helper'

describe Node do
  before :each do
    @node = FactoryGirl.build(:node)
    @node_link = FactoryGirl.build(:node_link, :source_id=>"a", :target_id=>"b")
  end

  describe "#has_link?" do
    it "should return false if not found" do
      @node.has_link?(@node_link).should eq(false)
    end

    it "should return true if found" do
      @node.node_links << @node_link
      @node.has_link?(@node_link).should eq(true)
    end
  end

  describe "#add_link!" do
    it "should add link if not found" do
      @node.add_link!(@node_link)
      @node.node_links.length.should eq(1)
    end

    it "should only add once" do
      @node.add_link!(@node_link)
      @node.add_link!(@node_link)
      @node.node_links.length.should eq(1)
    end
  end
end
