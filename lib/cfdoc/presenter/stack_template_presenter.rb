require 'cgi'

module CFDoc
  module Presenter
    class StackTemplatePresenter < CFDoc::Presenter::Base
      def render_inspect(stack_template)
        stack_template.inspect
      end

      # Primary render method to call from an ERB template or elsewhere. Returns the rendered HTML
      def render_html(stack_template, html_template='default_theme/stack_template.html.erb')
        render_erb({ :presenter=>self, :stack_template=>stack_template }, html_template)
      end

      #
      # -- Render helpers available to templates via the presenter local var
      #

      def render_resource_groups_html(stack_template, groups_list)
        result = ""
        groups_list.each do |group_id|
          if !stack_template.resources_in_group(group_id).empty?
            group_details = CFDoc::Model::ResourceSupport::GROUP_MAPPINGS[group_id]
            result += "<h3 class='#{group_id}'>#{group_details['display_name']}</h3>"
            result += "<div class='group #{group_id}'>"
            stack_template.resources_in_group(group_id).each do |resource|
              result += render_resource_html(resource)
            end
            result += "</div>"
          end
        end
        result
      end

      def render_resource_html(resource)
        result = ""
        result += "<div id=\"#{resource.key}\" class='resource #{resource['type'].underscore}'>"
        result += "<div class='name'>#{resource.name}</div>"
        result += "<div class='type'>#{resource['type']}</div>"
        result += "<div class='description'>#{render_descriptions_html(resource)}</div>"
        result += "<div class='details expandable'>"
        result += "<div class='vendor'>#{render_vendors_html(resource)}</div>"
        if resource.children.empty?
          result += "<p class='empty'>&lt;Empty&gt;</p>"
        end
        unless resource.properties.empty?
          result += "<div class=\"properties\">"
          result += "<h4>Properties</h4>"
          resource.properties.each do |property|
            result += "#{render_property_html(property)}"
          end
          result += "</div>"
        end

        unless resource.other_elements.empty?
          result += "<div class=\"elements\">"
          result += "<h4>Other elements</h4>"
          resource.other_elements.each do |element|
            result += "#{render_element_html(element)}"
          end
          result += "</div>"
        end

        result += "</div>"
        result += "<div class=\"resource_separator\"></div>"
        result += "</div>"
        result
      end

      def render_source_html(io)
        result = "<pre class='source'>"
        result += io.readlines.join("")
        result += "</pre>"
        result
      end

      def render_description_html(description)
        # break out any warnings that are commonly embedded
        desc = description
        warn = nil
        m = description.match(/(.*)(\ \*\*WARNING\*\*\ .*)/)
        if m
          desc = m[1]
          warn = m[2]
        end
        result = "<div class='description'>"
        result += "<div class='desc'>#{desc}</div>"
        result += "<div class='warning'>#{warn}</div>" unless warn.nil?
        result += "</div>"
        result
      end

      def render_element_html(element)
        result    = "<div class='element #{element.name.underscore}'>"
        result += "<div class='name'>#{element.name}</div>"
        result += "<div class='details'>"
        if !element.children.empty?
          result += "<div class='children'>"
          element.children.each do |child|
            if child.kind_of?(CFDoc::Model::Function)
              result += render_function_html(child)
            elsif child.kind_of?(CFDoc::Model::List)
              # This is a special case: don't render the list directly, as it will be rendered as fields below
            else
              result += render_element_html(child)
            end
          end
          result += "</div>"
        end
        if !element.fields.empty?
          result += "<div class='fields'>#{render_value_html(element.fields)}</div>"
        end
        result += "</div>"
        result += "</div>"
      end

      def render_property_html(element)
        result = ""
        if element.kind_of?(CFDoc::Model::Function)
          result += render_function_html(element)
        elsif element.kind_of?(CFDoc::Model::Ref)
          result = "<div class='ref'>"
          result += "Ref:#{element.name}"
          result += "</div>"
        elsif element.kind_of?(CFDoc::Model::CodeBlock)
          result += "<pre>#{element.code}</pre>"
        elsif element.kind_of?(CFDoc::Model::List)
          return "&lt;empty&gt;" if element.children.empty?
          result = "<ul class='property list'>"
          element.children.each do |val|
            result += "<li>#{render_property_html(val)}</li>"
          end
          result += "</ul>"
        elsif element.kind_of?(CFDoc::Model::Property)
          result = "<div class='property'>"
          if element.value
            result += "<div class='name'>#{element.name}</div>"
            result += "<div class='value'>#{render_property_html(element.value)}</div>"
          end
          if element.children?
            element.children.each do |child|
              result += "<div class='name'>#{element.name}</div>"
              result += render_property_html(child)
            end
          end
          result += "</div>"
        else
          result += "#{element}"
        end
      end

      def render_value_html(value)
        result = ""
        if value.kind_of?(Array)
          return "&lt;empty&gt;" if value.empty?
          #result = "<ul class='list'>"
          #value.each do |val|
          #  result += "<li>#{render_value_html(val)}</li>"
          #end
          #result += "</ul>"
          result += "#{value.join(", ")}"
        elsif value.kind_of?(Hash)
          return "" if value.empty?
          result = "<ul class='name_value'>"
          value.each_pair do |name, val|
            nested_val = render_value_html(val)
            nested_val = nil if nested_val.strip.empty?
            result += "<li>#{[name, nested_val].compact.join('<span class=\'separator\'> => </span>')}</li>"
          end
          result += "</ul>"
        elsif value.kind_of?(CFDoc::Model::CodeBlock)
          result += "<pre>#{value.code}</pre>"
        elsif value.kind_of?(CFDoc::Model::Function)
          result += render_function_html(value)
        elsif value.kind_of?(CFDoc::Model::List)
          return "&lt;empty&gt;" if value.children.empty?
          result = "<ul class='list'>"
          value.children.each do |val|
            result += "<li>#{render_value_html(val)}</li>"
          end
          result += "</ul>"
        elsif value.kind_of?(CFDoc::Model::Element)
          # Fallback - should be the last one in the list
          result += render_element_html(value) unless element.empty?
        else
          result = escape(value)
        end
        result
      end

      def render_function_html(function, join_str='<span class="fn_separator">, </span>')
        result = "<span class='function'>"
        arg_results = []
        function.arguments.each do |arg|
          arg_results << render_argument_html(arg, join_str)
        end
        result += "<span class='fn_name'>#{function.name}</span><span class='fn_args'>(#{arg_results.join(join_str)})</span>"
        result += "</span>"
        result
      end

      def render_argument_html(args, join_str='<span class="fn_separator">, </span>')
        if args.kind_of?(String)
          "<span class='fn_arg'>\"#{escape(args)}\"</span>"
        elsif args.kind_of?(Array)
          args.map { |a| render_argument_html(a)}.join(join_str)
        elsif args.kind_of?(CFDoc::Model::Function)
          render_function_html(args)
        end
      end

      def render_mapping_html(mapping)
        result = ""
        if mapping.kind_of?(String)
          result = mapping
        elsif mapping.kind_of?(Array)
          mapping.each do |child|
            result += render_mapping_html(child)
          end
        elsif mapping.kind_of?(CFDoc::Model::Mapping)
          result += "<div class='mapping_values'>"
          result += "<div class='name'>#{mapping.name}</div>"
          result += "<div class='value'>#{escape(mapping.value)}"
          mapping.children.each do |child|
            result += render_mapping_html(child)
          end
          result += "</div>"
          result += "</div>"
        end
        result
      end

      def render_descriptions_html(resource)
        result = ""
        resource.descriptions.each do |desc|
          result += "<span class='description_item'>#{desc.description}</span><br/>"
        end
        result
      end

      def render_vendors_html(resource)
        result = ""
        resource.vendors.each do |vendor|
          result += "<div class='#{vendor.name.underscore} #{vendor.description.underscore}'>#{vendor.description}</div>"
        end
        result
      end

      # File actionpack/lib/action_view/helpers/text_helper.rb, line 257
      def simple_format(text)
        text = '' if text.nil?
        start_tag = 'p'
        text = text.to_str
        text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
        text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
        text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
        text.insert 0, start_tag
        text += "</p>"
        text
      end

      def escape(orig)
        return nil if orig.nil?
        CGI.escapeHTML(orig)
      end

    end
  end
end
