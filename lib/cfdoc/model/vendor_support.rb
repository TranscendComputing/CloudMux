module CFDoc
  module Model
    module VendorSupport

      def vendors
        metadata = child('Metadata')
        if metadata
          metadata.children.select { |e| e.vendor?}
        else
          []
        end
      end

    end
  end
end
