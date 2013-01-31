module CFDoc
  module Model
    class Parameter < CFDoc::Model::Element
      include CFDoc::Model::PropertySupport

      def description; fields['description']; end
      def type; fields['type']; end
      def default; fields['default']; end
      def no_echo; fields['no_echo']; end
      def allowed_values; fields['allowed_values']; end
      def allowed_pattern; fields['allowed_pattern']; end
      def min_length; fields['min_length']; end
      def max_length; fields['max_length']; end
      def min_value; fields['min_value']; end
      def max_value; fields['max_value']; end
      def constraint_description; fields['constraint_description']; end

    end
  end
end
