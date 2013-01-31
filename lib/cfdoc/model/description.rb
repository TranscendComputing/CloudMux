module CFDoc
  module Model
    class Description < CFDoc::Model::Element
      attr :description

      def initialize(name, description)
        super(name)
        @description = description
      end
    end
  end
end
