module CFDoc
  module Model
    class List < CFDoc::Model::Element
      attr :items

      def initialize(name=nil)
        super(name)
        @items = Array.new
      end

      # override the default element behavior that restricts children, allowing the list to capture any values in the list, including Strings
      # def <<(child)
      #   @children << child
      #   @children_hash[child.name] = child if child.kind_of?(CFDoc::Model::Element) and !child.name.nil?
      # end
    end
  end
end
