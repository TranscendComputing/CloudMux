module CFDoc
  module Parser
    class CFParser

      # Match element names that follow the Function naming convention (start with Fn::)
      FUNCTION_REGEX = /^Fn::/
      REF_REGEX = /^Ref$/
      METADATA_REGEX = /^Metadata$/
      DESCRIPTION_REGEX = /[Cc]omment[0..9]?|[Dd]escription/
      PLATFORM_REGEX = /[Pp]latform/

      #
      # Scans and parses an IO, returning a StackTemplate model fully populated
      #
      def scan(io)
        if io.kind_of?(IO)
          json = JSON::parse(io.readlines.join("\n"))
          io.rewind
        else
          json = JSON::parse(io)
        end
        # rewind the IO so that it can be processed again using the same handle
        template = CFDoc::Model::StackTemplate.new
        template.description = json['Description']
        template.version = json['AWSTemplateFormatVersion']
        json['Parameters'].each do |json_param|
          param = parse_parameter(json_param)
          template << param unless param.nil?
        end if json['Parameters']
        json['Mappings'].each do |json_mapping|
          mapping = parse_mapping_set(json_mapping)
          template << mapping unless mapping.nil?
        end if json['Mappings']
        json['Resources'].each do |json_res|
          # a Resource is an array of [name, {fields_hash}]
          res = parse_resource(json_res)
          template << res unless res.nil?
        end if json['Resources']
        json['Outputs'].each do |json_output|
          output = parse_output(json_output)
          template << output unless output.nil?
        end if json['Outputs']
        io.rewind if io.kind_of?(IO)
        template
      end

      # builds a Parameter model given the json payload
      def parse_parameter(parsed_json)
        # a Parameter is an array of [name, {fields_hash}]
        name, fields = parsed_json[0], parsed_json[1]
        param = CFDoc::Model::Parameter.new(name)
        # TODO: better parse and add array support?
        param.fields = fields
        param
      end

      # builds a MappingSet model given the json payload
      def parse_mapping_set(parsed_json)
        # a Parameter is an array of [name, {fields_hash}]
        name, fields = parsed_json[0], parsed_json[1]
        mapping_set = CFDoc::Model::MappingSet.new(name)
        parse_mapping(mapping_set, fields)
        mapping_set
      end

      # builds a Resource model given the json payload
      def parse_resource(parsed_json)
        name, fields = parsed_json[0], parsed_json[1]
        res = CFDoc::Model::Resource.new(name)
        parse_element(res, fields)
        res
      end

      # builds an Output model given the json payload
      def parse_output(parsed_json)
        # a Resource is an array of [name, {fields_hash}]
        name, fields = parsed_json[0], parsed_json[1]
        output = CFDoc::Model::Output.new(name)
        parse_element(output, fields)
        output
      end

      #
      # recursively examine any kind of element, populating the element with the fields and children found and returning it
      #
      def parse_element(element, fields)
        # Handle properties in a special way, for better rendering and management
        properties = fields.delete('Properties')
        parse_properties(element, properties) if properties

        # look at the remaining fields, grabbing each one that isn't a simple string and capture them as child elements
        fields.each_pair do |field_name, field_val|
          if field_name.match(FUNCTION_REGEX)
            extracted = fields.delete(field_name) # remove the entry so that we are left with only entries that we want to treat as element fields
            nested = CFDoc::Model::Function.new(field_name)
            parse_function(nested, field_val)
            element << nested unless nested.nil?
          elsif field_name.match(REF_REGEX)
            ref = CFDoc::Model::Ref.new(field_val)
            element << ref
          elsif field_name.match(DESCRIPTION_REGEX) and element.metadata? # only process this if it is part of a Metadata element
            fields.delete(field_name)
            desc = CFDoc::Model::Description.new(field_name, field_val)
            element << desc
          elsif field_name.match(PLATFORM_REGEX) and element.metadata? # only process this if it is part of a Metadata element
            fields.delete(field_name)
            vendor = CFDoc::Model::Platform.new(field_name, field_val)
            element << vendor
          elsif field_name.match(METADATA_REGEX)
            metadata = CFDoc::Model::Metadata.new(field_name)
            parse_element(metadata, field_val)
            element << metadata
          elsif field_val.kind_of?(Array)
            # don't do anything - it will be captured as a field whose value is an array
          elsif field_val.kind_of?(Hash)
            extracted = fields.delete(field_name) # remove the entry so that we are left with only entries that we want to treat as element fields
            nested = CFDoc::Model::Element.new(field_name)
            parse_element(nested, extracted)
            element << nested unless nested.nil?
          end
        end

        element.fields = fields
        element
      end

      #
      # recursively examine and model the properties found, populating the element and returning it with any child elements attached
      #
      def parse_properties(element, properties)
        properties.each_pair do |name, prop_fields|
          if name == 'UserData'
            # Special case
            code = extract_code(prop_fields)
            element << CFDoc::Model::Property.new(name, CFDoc::Model::UserData.new(name, code))
          elsif name.match(REF_REGEX)
            # TODO: resolve - we may need to wait, as some are a forward-reference and haven't been parsed yet. Perhaps another pass? Or, resolve on demand?
            ref = CFDoc::Model::Ref.new(prop_fields)
            if element.property?
              element.value = ref
            else
              element << ref
            end
          elsif name.match(FUNCTION_REGEX)
            func = CFDoc::Model::Function.new(name)
            parse_function(func, prop_fields)
            element << func
          elsif prop_fields.kind_of?(Hash)
            prop = CFDoc::Model::Property.new(name)
            parse_properties(prop, prop_fields)
            element << prop
          elsif prop_fields.kind_of?(Array)
            prop = CFDoc::Model::Property.new(name)
            list = CFDoc::Model::List.new(nil) # no name for lists that are used as values for a property
            prop_fields.each do |item|
              if item.kind_of?(Hash)
                # recurse the hash, allowing subsequent calls to fill the list with properties (and possibly nested properties)
                parse_properties(list, item)
              else
                list.items << item
              end
            end
            prop.value = list
            element << prop
          elsif prop_fields.kind_of?(String)
            prop = CFDoc::Model::Property.new(name, prop_fields)
            element << prop
          end
        end
        element
      end

      #
      # recursively examine and model a function, populating it and returning it with any child elements and arguments attached
      #
      def parse_function(function, args)
        # TODO: handle Refs
        if args.kind_of?(Hash)
          args.each_pair do |nested_name, nested_values|
            nested = CFDoc::Model::Function.new(nested_name)
            parse_function(nested, nested_values)
            function.arguments << nested
          end
        elsif args.kind_of?(Array)
          # TODO: capture into an array type?
          args.each { |a| parse_function(function, a)}
        elsif args.kind_of?(String)
          function.arguments << args
        end
      end

      def parse_mapping(element, fields)
        if fields.kind_of?(String)
          element.value = fields
        elsif fields.kind_of?(Array)
          list = CFDoc::Model::List.new(nil)
          fields.each do |item|
            if item.kind_of?(String)
              list.items << item
            else
              parse_mapping(list, item)
            end
          end
          element << list
        elsif fields.kind_of?(Hash)
          fields.each_pair do |field_name, field_val|
            mapping = CFDoc::Model::Mapping.new(field_name)
            parse_mapping(mapping, field_val)
            element << mapping
          end
        end
        element
      end

      #
      # extracts the code from a block, typically enclosed in a Base64 and/or Join function. Usually applied to specific elements, such as UserData
      #
      def extract_code(fields)
        fields = fields.delete('Fn::Base64') || fields
        if fields.kind_of?(Hash)
          fields = fields.delete('Fn::Join') || fields
        end
        if fields.kind_of?(Array)
          sep = fields.shift
          fields = fields.join(sep)
        end
        fields
      end

    end
  end
end
