module CFDoc
  module Model
    class Property < CFDoc::Model::Element
      attr :value, true

      def initialize(name, value=nil)
        super(name)
        @value = value
      end
    end
  end
end
