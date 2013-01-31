module CFDoc
  module Model
    class Function < CFDoc::Model::Element
      attr :arguments, true

      def initialize(name)
        super(name)
        @arguments = Array.new
      end
    end
  end
end
