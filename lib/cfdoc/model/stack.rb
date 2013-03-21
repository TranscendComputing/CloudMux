module CFDoc
  module Model
    class Stack
      attr :templates # TODO: is this a 1-to-1 or 1-to-many?

      def initialize
        @templates = Array.new
      end

      def <<(obj)
        raise "Argument is not an template" unless supported?(obj)
        @templates << obj if obj.kind_of?(StackTemplate)
      end

      protected

      def supported?(obj)
        return (obj.kind_of?(StackTemplate))
      end

    end
  end
end
