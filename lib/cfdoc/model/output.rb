module CFDoc
  module Model
    class Output < CFDoc::Model::Element
      include CFDoc::Model::PropertySupport

      def value
        child('Value') || fields['value'] # in case we have a simple output value, rather than a child element
      end

      def description
        fields['description']
      end

    end
  end
end
