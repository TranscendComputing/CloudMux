module CFDoc
  module Model
    module DescriptionSupport

      def descriptions
        metadata = child('Metadata')
        if metadata
          metadata.children.select { |e| e.description?}
        else
          []
        end
      end

      def other_elements
        # NOTE: if this mixin is used without the PropertySupport mixin, it could have bad consequences. May need to revisit this in the future
        children.select { |e| !e.property? and !e.description?}
      end

    end
  end
end
