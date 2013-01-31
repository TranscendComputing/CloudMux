module CFDoc
  module Model
    class Resource < CFDoc::Model::Element
      include CFDoc::Model::PropertySupport
      include CFDoc::Model::DescriptionSupport
      include CFDoc::Model::ResourceSupport
      include CFDoc::Model::VendorSupport

      attr :group_mapping # calculated after fields are set

      def type
        fields['type']
      end

      def fields=(fields)
        super(fields)
        # pre-calc the group mapping, based on the type of resource. See ResourceSupport class
        @group_mapping = calc_group unless type.nil? or type.empty?
      end
    end
  end
end
