require 'cfdoc_spec_helper'

describe CFDoc::Presenter::StackTemplatePresenter do

  before :each do
    @presenter = CFDoc::Presenter::StackTemplatePresenter.new
  end

  describe "#render_value_html" do
    before :each do
    end

    it "should return the value back by default" do
      expected = "My String"
      @presenter.render_value_html(expected).should eq(expected)
    end

    it "should render an array as a list" do
      a = ["Item 1", "Item 2"]
      expected = "Item 1, Item 2"
      @presenter.render_value_html(a).should eq(expected)
    end

    it "should render a hash as a list" do
      h = {"Item 1"=>"Value 1", "Item 2"=>"Value 2"}
      expected = "<ul class='name_value'><li>Item 1<span class='separator'> => </span>Value 1</li><li>Item 2<span class='separator'> => </span>Value 2</li></ul>"
      @presenter.render_value_html(h).should eq(expected)
    end

    it "should render a hash with an array" do
      h = {"Item 1"=>"Value 1", "Item 2"=>["Value 2a", "Value 2b"]}
      expected = "<ul class='name_value'><li>Item 1<span class='separator'> => </span>Value 1</li><li>Item 2<span class='separator'> => </span>Value 2a, Value 2b</li></ul>"
      @presenter.render_value_html(h).should eq(expected)
    end
  end

  describe "#render_function_html" do
    it "should render a function with a nested function arg" do
      expected = "<span class='function'><span class='fn_name'>Fn::Join</span><span class='fn_args'>(<span class='fn_arg'>\"\"</span><span class=\"fn_separator\">, </span><span class='fn_arg'>\"http://\"</span><span class=\"fn_separator\">, </span><span class='function'><span class='fn_name'>Fn::GetAtt</span><span class='fn_args'>(<span class='fn_arg'>\"ElasticLoadBalancer\"</span><span class=\"fn_separator\">, </span><span class='fn_arg'>\"DNSName\"</span>)</span></span>)</span></span>"
      # setup
      @parser = CFDoc::Parser::CFParser.new
      @e = CFDoc::Model::Element.new("WebsiteURL")
      @args = {
        "Value" => { "Fn::Join" => ["", ["http://", { "Fn::GetAtt" => [ "ElasticLoadBalancer", "DNSName" ]}]] },
        "Description" => "URL for newly created Rails application"
      }
      element = @parser.parse_element(@e, @args)
      function = element.child("Value").child('Fn::Join')

      result = @presenter.render_function_html(function)
      result.should eq(expected)
    end
  end
end
