module CFDoc
  module Model
    module PropertySupport

      def properties
        children.select { |e| e.kind_of?(CFDoc::Model::Property)}
      end

      def other_elements
        children.select { |e| !e.kind_of?(CFDoc::Model::Property)}
      end

    end
  end
end
