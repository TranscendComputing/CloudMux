module CFDoc
  module Presenter
    class Base
      attr :eruby

      def render_erb(bindings, html_template)
        input = File.read(File.join(File.dirname(__FILE__), html_template))
        @eruby = Erubis::Eruby.new(input)
        @eruby.result(bindings)
      end
    end
  end
end
