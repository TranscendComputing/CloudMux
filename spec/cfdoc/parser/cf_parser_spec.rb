require 'cfdoc_spec_helper'

describe CFDoc::Parser::CFParser do
  before :each do
    @file = File.new(File.join(File.dirname(__FILE__), '..', '..', 'cfdoc_fixtures', 'careers_formation.json'))
    @json = JSON::parse(File.new(@file.path).readlines.join("\n"))
    @parser = CFDoc::Parser::CFParser.new
  end

  describe "#extract_code" do
    it "should extract base64 and joined content" do
      expected_code = <<-EOF
#!/bin/sh
/opt/aws/bin/cfn-init  -s {"Ref"=>"AWS::StackName"} -r LaunchConfig --access-key={"Ref"=>"QueueUserKeys"} --secret-key={"Fn::GetAtt"=>["QueueUserKeys", "SecretAccessKey"]}
/usr/bin/ruby /home/ec2-user/post.rb /home/ec2-user/config.yml &
EOF
      parsed_fields = @json["Resources"]["LaunchConfig"]["Properties"]["UserData"]
      parsed_fields.should_not eq(nil)
      code = @parser.extract_code(parsed_fields)
      code.should_not eq(nil)
      code.should eq(expected_code)
    end
  end

  describe "#parse_parameter" do
    it "should parse the fields" do
      parsed_json = [ "EmailAddress", {
          "Description" => "Email address for infrastructure notifications",
          "Type" => "String"
        }]
      param = @parser.parse_parameter(parsed_json)
      param.should_not eq(nil)
      param.description.should eq("Email address for infrastructure notifications")
      param.name.should eq("EmailAddress")
      param.type.should eq("String")
      param.children.empty?.should eq(true)
    end
  end

  describe "#parse_properties" do
    it "should parse a simple property " do
      parsed_json = {
        "GroupName"=> "MyGroup"
      }
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_properties(e, parsed_json)
      e.children.length.should eq(1)
      group_name_prop = e.child("GroupName")
      group_name_prop.property?.should eq(true)
      group_name_prop.should_not eq(nil)
      group_name_prop.value.should eq("MyGroup")
      group_name_prop.children.length.should eq(0)
    end

    it "should parse properties with nested property " do
      parsed_json = {
          "GroupName"=> { "Ref" => "QueueGroup" }
      }
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_properties(e, parsed_json)
      e.children.length.should eq(1)
      group_name_prop = e.child("GroupName")
      group_name_prop.property?.should eq(true)
      group_name_prop.should_not eq(nil)
      group_name_prop.value.should_not eq(nil)
      group_name_prop.value.ref?.should eq(true)
      group_name_prop.value.name.should eq("QueueGroup")
      group_name_prop.children.length.should eq(0)
    end

    it "should parse properties with array values" do
      parsed_json = {
          "Users" => [ { "Ref" => "QueueUser" } ]
      }
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_properties(e, parsed_json)
      e.children.length.should eq(1)
      group_name_prop = e.child("Users")
      group_name_prop.property?.should eq(true)
      group_name_prop.should_not eq(nil)
      group_name_prop.children.length.should eq(0)
      value = group_name_prop.value
      value.should_not eq(nil)
      value.list?.should eq(true)
      value.children.length.should eq(1)
      value.children.first.name.should eq("QueueUser")
    end

    it "should parse a property with functions" do
      args = {
          "SourceSecurityGroupOwnerId" => {"Fn::GetAtt" => ["ElasticLoadBalancer", "SourceSecurityGroup.OwnerAlias"]}
      }
      e = CFDoc::Model::Element.new("My Name")
      result = @parser.parse_properties(e, args)
      result.children.length.should eq(1)
      child = result.child("SourceSecurityGroupOwnerId")
      fn = child.child("Fn::GetAtt")
      fn.function?.should eq(true)
      fn.arguments.length.should eq(2)
      fn.arguments[0].should eq("ElasticLoadBalancer")
      fn.arguments[1].should eq("SourceSecurityGroup.OwnerAlias")
    end

    it "should parse a property with a ref" do
      parsed_json = {
        "LaunchConfigurationName" => { "Ref" => "LaunchConfig" }
        }
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_properties(e, parsed_json)
      e.children.length.should eq(1)
      prop = e.children[0]
      prop.property?.should eq(true)
      ref = prop.value
      ref.should_not eq(nil)
      ref.ref?.should eq(true)
      ref.name.should eq("LaunchConfig")
    end
  end

  describe "#parse_function" do
    it "should convert a function with a function arg" do
      args = {
        "Value" => { "Fn::Join" => ["", ["http://", { "Fn::GetAtt" => [ "ElasticLoadBalancer", "DNSName" ]}]] },
        "Description" => "URL for newly created Rails application"
      }
      e = CFDoc::Model::Element.new("WebsiteURL")
      result = @parser.parse_element(e, args)
      result.children.length.should eq(1)
      result.name.should eq("WebsiteURL")
      result['description'].should eq("URL for newly created Rails application")
      value = result.child("Value")
      value.name.should eq("Value")
      value.fields.length.should eq(0)
      value.children.length.should eq(1)
      fn_join = value.child('Fn::Join')
      fn_join.name.should eq("Fn::Join")
      fn_join.function?.should eq(true)
      fn_join.arguments.length.should eq(3)
      fn_join.arguments[0].should eq("")
      fn_join.arguments[1].should eq("http://")
      fn_get_att = fn_join.arguments[2]
      fn_get_att.function?.should eq(true)
      fn_get_att.arguments.length.should eq(2)
      fn_get_att.arguments[0].should eq("ElasticLoadBalancer")
      fn_get_att.arguments[1].should eq("DNSName")
    end
  end

  describe "#parse_output" do
    it "should parse the fields" do
      parsed_json = ["WebsiteURL", {
          #"Value" => { "Fn::Join" => ["", ["http://", { "Fn::GetAtt" => [ "ElasticLoadBalancer", "DNSName" ]}]] },
          "Value" => "http://localhost:3000",
          "Description" => "URL for newly created Rails application"
        }]
      output = @parser.parse_output(parsed_json)
      output.should_not eq(nil)
      output.description.should eq("URL for newly created Rails application")
      output.value.should eq("http://localhost:3000")
      output.children.empty?.should eq(true)
    end

    it "should parse a Value function" do
      parsed_json = ["WebsiteURL", {
          "Value" => { "Fn::Join" => ["", ["http://", { "Fn::GetAtt" => [ "ElasticLoadBalancer", "DNSName" ]}]] },
          "Description" => "URL for newly created Rails application"
        }]
      output = @parser.parse_output(parsed_json)
      output.children.length.should eq(1)
      value = output.value
      value.should_not eq(nil)
      value.kind_of?(CFDoc::Model::Element).should eq(true)
      value.name.should eq("Value")
      value.children.length.should eq(1)
      function = value.child('Fn::Join')
      function.function?.should eq(true)
    end
  end

  describe "#parse_element" do
    it "should parse fields" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup"
      }}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      instance_security_group.should_not eq(nil)
      instance_security_group.children.length.should eq(0)
      instance_security_group.fields.length.should eq(1)
      instance_security_group['type'].should eq("AWS::EC2::SecurityGroup")
    end

    it "should parse properties" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup",
      "Properties" => {
        "GroupDescription" => "Enable SSH",
        "SecurityGroupIngress" => [ {
          "IpProtocol" => "tcp",
          "FromPort" => "22",
          "ToPort" => "22",
          "CidrIp" => "0.0.0.0/0"
        } ]
      }}}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      instance_security_group.should_not eq(nil)
      instance_security_group.children.length.should eq(2) # 2 properties
      instance_security_group.children[0].name.should eq("GroupDescription")
      # simple check that the properties are being parsed properly
      prop_2 = instance_security_group.children[1]
      prop_2.name.should eq("SecurityGroupIngress")
      prop_2.value.should_not eq(nil)
      prop_2.value.list?.should eq(true)
      prop_2.value.children.length.should eq(4)
    end

    it "should parse an array of values within an element" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup",
      "SecurityGroupIngress" => [ # faked - haven't found a true example yet to use as a test, so contriving one
          "tcp",
          "22",
          "22",
          "0.0.0.0/0"
        ]
      }}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      instance_security_group.children.length.should eq(0)
      instance_security_group.fields.length.should eq(2)
      instance_security_group.fields['type'].should_not eq(nil)
      instance_security_group.fields['security_group_ingress'].should_not eq(nil)
    end

    it "should parse a Ref" do
    parsed_json = {
      "Type" => "AWS::AutoScaling::AutoScalingGroup",
      "LaunchConfigurationName" => { "Ref" => "LaunchConfig" }
        }
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      prop = e.child('LaunchConfigurationName')
      prop.should_not eq(nil)
      prop.children.length.should eq(1)
      ref = prop.children[0]
      ref.ref?.should eq(true)
      ref.name.should eq("LaunchConfig")
    end

    it "should parse metadata elements" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup",
      "Metadata" => {
        "entry" => "Configure the security group"
          }}}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      meta_data = instance_security_group.child('Metadata')
      meta_data.should_not eq(nil)
      meta_data.metadata?.should eq(true)
      meta_data.children.length.should eq(0)
      meta_data.fields.length.should eq(1)
      meta_data['entry'].should eq('Configure the security group')
    end

    it "should parse metadata Description" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup",
      "Metadata" => {
        "Description" => "Configure the security group"
          }}}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      meta_data = instance_security_group.child('Metadata')
      meta_data.should_not eq(nil)
      meta_data.metadata?.should eq(true)
      meta_data.children.length.should eq(1)
      comment = meta_data.child('Description')
      comment.should_not eq(nil)
      comment.description?.should eq(true)
      comment.description.should eq("Configure the security group")
      meta_data.fields.length.should eq(0)
    end

    it "should parse metadata Comment" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup",
      "Metadata" => {
        "Comment" => "Configure the security group"
          }}}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      meta_data = instance_security_group.child('Metadata')
      meta_data.should_not eq(nil)
      meta_data.metadata?.should eq(true)
      meta_data.children.length.should eq(1)
      comment = meta_data.child('Comment')
      comment.should_not eq(nil)
      comment.description?.should eq(true)
      comment.description.should eq("Configure the security group")
      meta_data.fields.length.should eq(0)
    end

    it "should parse multiple metadata Comments" do
      parsed_json =   { "InstanceSecurityGroup" => {
      "Type" => "AWS::EC2::SecurityGroup",
      "Metadata" => {
        "Comment1" => "Configure the security group",
        "Comment2" => "Configure the security group 2"
          }}}
      e = CFDoc::Model::Element.new("Root")
      e = @parser.parse_element(e, parsed_json)
      e.children.length.should eq(1)
      instance_security_group = e.child('InstanceSecurityGroup')
      meta_data = instance_security_group.child('Metadata')
      meta_data.should_not eq(nil)
      meta_data.metadata?.should eq(true)
      meta_data.children.length.should eq(2)
      comment_1 = meta_data.child('Comment1')
      comment_1.should_not eq(nil)
      comment_1.description?.should eq(true)
      comment_1.description.should eq("Configure the security group")
      comment_2 = meta_data.child('Comment2')
      comment_2.should_not eq(nil)
      comment_2.description?.should eq(true)
      comment_2.description.should eq("Configure the security group 2")
      meta_data.fields.length.should eq(0)
    end
  end

  describe "#parse_mapping" do
    it "should parse mappings for a mapping set" do
      parsed_json = {
                       "t1.micro"    => { "Arch" => "32" },
                       "m1.small"    => { "Arch" => "32" }
      }
      e = CFDoc::Model::Element.new("Root")
      mapping = @parser.parse_mapping(e, parsed_json)
      mapping.children.length.should eq(2)
      mapping.children[0].mapping?.should eq(true)
      mapping.children[0].name.should eq("t1.micro")
      mapping.children[0].value.should eq(nil)
      mapping.children[1].mapping?.should eq(true)
      mapping.children[1].name.should eq("m1.small")
      mapping.children[1].value.should eq(nil)
      t1_micro = mapping.children[0]
      t1_micro.name.should eq("t1.micro")
      t1_micro.children.length.should eq(1)
      t1_micro.children[0].name.should eq("Arch")
      t1_micro.children[0].value.should eq("32")
      m1_small = mapping.children[1]
      m1_small.name.should eq("m1.small")
      m1_small.children.length.should eq(1)
      m1_small.children[0].name.should eq("Arch")
      m1_small.children[0].value.should eq("32")
    end
  end

  describe "#parse_resource" do
    it "should parse the fields" do
      parsed_json = [ "QueueUsers", {
        "Type" => "AWS::IAM::UserToGroupAddition"
      }]
      resource = @parser.parse_resource(parsed_json)
      resource.should_not eq(nil)
      resource.type.should eq("AWS::IAM::UserToGroupAddition")
      resource.children.empty?.should eq(true)
    end

    it "should parse a simple property " do
      parsed_json = [ "QueueUsers", {
        "Type" => "AWS::IAM::UserToGroupAddition",
        "Properties" => {
          "GroupName"=> "MyGroup"
        }
      }]
      resource = @parser.parse_resource(parsed_json)
      resource.children.length.should eq(1)
      resource.properties.length.should eq(1)
    end

    it "should parse a resource with a nested hash with an array of values" do
      parsed_json = [
        "AWS::CloudFormation::Init", {
              "rubygems" => {
                "rack"         => ["1.3.6"]
              }
            }]
      resource = @parser.parse_resource(parsed_json)
      resource.properties.length.should eq(0)
      resource.children.length.should eq(1)
      child = resource.children[0]
      child.name.should eq("rubygems")
      child.children.length.should eq(0)
      child.fields.length.should eq(1)
      child.fields['rack'][0].should eq("1.3.6")
      child.children.length.should eq(0)
    end
  end

  describe "#parse_mapping_set" do
    it "should parse the fields" do
      parsed_json = ["AWSInstanceType2Arch", {
      }]
      mapping_set = @parser.parse_mapping_set(parsed_json)
      mapping_set.should_not eq(nil)
      mapping_set.name.should eq("AWSInstanceType2Arch")
    end

    it "should parse one-level nesting of mappings" do
      parsed_json = ["AWSInstanceType2Arch", {
                       "t1.micro"    => {  },
                       "m1.small"    => {  }
      }]
      mapping_set = @parser.parse_mapping_set(parsed_json)
      mapping_set.children.length.should eq(2)
      mapping_set.children[0].name.should eq("t1.micro")
      mapping_set.children[1].name.should eq("m1.small")
    end

    it "should parse multi-level nesting of mappings" do
      parsed_json = ["AWSInstanceType2Arch", {
                       "t1.micro"    => { "Arch" => "32" },
                       "m1.small"    => { "Arch" => "32" }
      }]
      mapping_set = @parser.parse_mapping_set(parsed_json)
      t1_micro = mapping_set.children[0]
      t1_micro.name.should eq("t1.micro")
      t1_micro.children.length.should eq(1)
      t1_micro.children[0].name.should eq("Arch")
      t1_micro.children[0].value.should eq("32")
      m1_small = mapping_set.children[1]
      m1_small.name.should eq("m1.small")
      m1_small.children.length.should eq(1)
      m1_small.children[0].name.should eq("Arch")
      m1_small.children[0].value.should eq("32")
    end
  end

  describe "#scan" do
    before :each do
      @stack_template = @parser.scan(@file)
    end

    it "should return a StackTemplate model" do
      @stack_template.class.should eq(CFDoc::Model::StackTemplate)
    end

    it "should parse Parameters" do
      names = ["EmailAddress", "KeyName", "QueueName"]
      @stack_template.parameters.length.should eq(names.length)
      @stack_template.parameters.collect(&:name).sort.should eq(names)
    end

    it "should parse Resources" do
      names = ["CFNUserPolicies", "EmailTopic", "InstanceSecurityGroup", "JobQueueDepthTrigger", "LaunchConfig", "ProcessorInstance", "QueueGroup", "QueueNonEmptyAlarm", "QueueUser", "QueueUserKeys", "QueueUsers"]
      @stack_template.resources.length.should eq(names.length)
      @stack_template.resources.collect(&:name).sort.should eq(names)
    end

    it "should parse UserData under a LaunchConfig" do
      config = @stack_template.resource("LaunchConfig")
      config.should_not eq(nil)
      user_data = config.child("UserData")
      user_data.should_not eq(nil)
      user_data.value.kind_of?(CFDoc::Model::UserData).should eq(true)
      expected_code = <<-EOF
#!/bin/sh
/opt/aws/bin/cfn-init  -s {"Ref"=>"AWS::StackName"} -r LaunchConfig --access-key={"Ref"=>"QueueUserKeys"} --secret-key={"Fn::GetAtt"=>["QueueUserKeys", "SecretAccessKey"]}
/usr/bin/ruby /home/ec2-user/post.rb /home/ec2-user/config.yml &
EOF
      user_data.value.code.should eq(expected_code)
    end

    it "should parse child elements for a resource" do
      config = @stack_template.resource("LaunchConfig")
      config.should_not eq(nil)
      metadata = config.child("Metadata")
      metadata.should_not eq(nil)
    end

    it "should parse Outputs" do
      # need to use a different template for this one
      @file = File.new(File.join(File.dirname(__FILE__), '..', '..', 'cfdoc_fixtures', 'rails_multi_az.json'))
      @parser = CFDoc::Parser::CFParser.new
      @stack_template = @parser.scan(@file)
      @stack_template.outputs.length.should eq(1)
      output = @stack_template.outputs.first
      output.name.should eq("WebsiteURL")
      value = output.child('Value')
      value.should_not eq(nil)
      fn_join = value.child('Fn::Join')
      fn_join.should_not eq(nil)
      fn_join.function?.should eq(true)
      output['description'].should eq("URL for newly created Rails application")
    end
  end

  describe "parser should not fail for all example fixtures" do
    it "should parse each sample fixture without error" do
      files = Dir.glob(File.join(File.dirname(__FILE__), "..", "..", "cfdoc_fixtures", "**", "*.json"))
      files.each do |filename|
        parser = CFDoc::Parser::CFParser.new
        begin
          stack_template = parser.scan(File.new(filename).read)
        rescue => e
          fail "Error parsing file: #{filename}. #{e}\n#{e.backtrace[0..3].join("\n")}"
        end
      end
    end
  end

  describe "presenter should not fail for all example fixtures" do
    it "should render each sample fixture without error" do
      files = Dir.glob(File.join(File.dirname(__FILE__), "..", "..", "cfdoc_fixtures", "**", "*.json"))
      files.each do |filename|
        parser = CFDoc::Parser::CFParser.new
        stack_template = parser.scan(File.new(filename).read)
        t_presenter = CFDoc::Presenter::StackTemplatePresenter.new
        begin
          t_presenter.render_html(stack_template)
        rescue => e
          fail "Error rendering file: #{filename}. #{e}\n#{e.backtrace[0..3].join("\n")}"
        end
      end
    end
  end

end
