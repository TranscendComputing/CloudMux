module CFDoc
  module Model
    class Element
      attr :name,true
      # TODO: add an attached() callback and hook in the parent when the instance is added as a child?
      attr :parent,true
      attr :children
      attr :fields

      def initialize(name)
        @name = name
        @children = []
        @children_hash = {}
        @fields = {}
      end

      def fields=(fields_hash)
        (fields_hash || { }).each_pair do |name, val|
          key = name.underscore
          @fields[key] = val
        end
      end

      def <<(child)
        raise "Argument is not an element: #{child}" unless child.kind_of?(Element)
        @children << child
        @children_hash[child.name] = child unless child.name.nil?
      end

      # return a child by name (currently one level deep only)
      def child(name)
        @children_hash[name.to_s]
      end

      def children?
        !@children.empty?
      end

      def [](key)
        @fields[key.to_s]
      end

      # returns a key that can be used as a dom id, link anchor, or other identification
      def key
        @name.nil? ? nil : @name.underscore
      end

      def empty?
        (@fields.empty? and @children.empty?)
      end

      def resource?
        self.kind_of?(CFDoc::Model::Resource)
      end

      def parameter?
        self.kind_of?(CFDoc::Model::Parameter)
      end

      def output?
        self.kind_of?(CFDoc::Model::Output)
      end

      def function?
        self.kind_of?(CFDoc::Model::Function)
      end

      def code_block?
        self.kind_of?(CFDoc::Model::CodeBlock)
      end

      def mapping_set?
        self.kind_of?(CFDoc::Model::MappingSet)
      end

      def mapping?
        self.kind_of?(CFDoc::Model::Mapping)
      end

      def property?
        self.kind_of?(CFDoc::Model::Property)
      end

      def ref?
        self.kind_of?(CFDoc::Model::Ref)
      end

      def list?
        self.kind_of?(CFDoc::Model::List)
      end

      def metadata?
        self.kind_of?(CFDoc::Model::Metadata)
      end

      def description?
        self.kind_of?(CFDoc::Model::Description)
      end

      def vendor?
        self.kind_of?(CFDoc::Model::Vendor)
      end

    end

  end
end
