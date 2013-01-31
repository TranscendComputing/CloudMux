module CFDoc
  module Model
    class CodeBlock < CFDoc::Model::Element
      attr :code

      def initialize(name, code)
        super(name)
        @code = code
      end
    end
  end
end
