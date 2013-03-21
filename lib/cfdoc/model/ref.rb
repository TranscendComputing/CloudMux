require 'weakref'

module CFDoc
  module Model
    class Ref < CFDoc::Model::Element

      # TODO: should we resolve references? If so, we need a context
      # to be passed with a resolver API (on the parser itself, or
      # the stack/top level project?) or parent ref so that we can ask it to resolve for us?

    end
  end
end
