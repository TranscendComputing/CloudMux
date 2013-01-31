module CFDoc
  module Model
    class StackTemplate
      attr :description, true
      attr :version, true
      attr :elements

      def initialize
        @elements = Array.new
        @resources_hash = Hash.new
        @parameters_hash = Hash.new
        @outputs_hash = Hash.new
        @mappings_hash = Hash.new
      end

      # add an element to the stack. Must be a type or subtype of Element
      def <<(element)
        raise "Argument cannot be nil" if element.nil?
        raise "Argument is not an element" unless element.kind_of?(Element)
        @elements << element
        # Hash it for faster lookup and reference resolution
        if element.resource?
          @resources_hash[element.name] = element unless element.name.nil?
        elsif element.parameter?
          @parameters_hash[element.name] = element unless element.name.nil?
        elsif element.output?
          @outputs_hash[element.name] = element unless element.name.nil?
        elsif element.mapping?
          @mappings_hash[element.name] = element unless element.name.nil?
        end
      end

      # return only elements that are parameters
      def parameters
        elements.select { |e| e.parameter?}
      end

      # return only elements that are mapping_sets
      def mapping_sets
        elements.select { |e| e.mapping_set?}
      end

      # return only elements that are resources
      def resources
        elements.select { |e| e.resource?}
      end

      # return only elements that are outputs
      def outputs
        elements.select { |e| e.output?}
      end

      # lookup a parameter by name and return if found
      def parameter(name)
        @parameters_hash[name.to_s]
      end

      # lookup a resource by name and return if found
      def resource(name)
        @resources_hash[name.to_s]
      end

      # lookup a output by name and return if found
      def output(name)
        @outputs_hash[name.to_s]
      end

      # filters the list of resources by a group id, returning the list of resources that belong
      def resources_in_group(group_id)
        resources.select { |r| !r.group_mapping.nil? and r.group_mapping[CFDoc::Model::ResourceSupport::ID] == group_id}
      end

      # returns the IDs of the resource groups that all templates
      # currently use. See CFDoc::Model::ResourceSupport for details
      def resource_group_ids
        resources.map { |r| r.calc_group[CFDoc::Model::ResourceSupport::ID] }.compact.uniq.sort
      end


    end
  end
end
