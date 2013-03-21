module CFDoc
  module Model
    class Vendor < CFDoc::Model::Element
      attr :description

      def initialize(name, description)
        super(name)
        @description = description
      end
    end
  end
end
