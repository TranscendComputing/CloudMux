class CloudService
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :cloud_account

  field :service_type, type:String
  field :path, type:String
  field :protocol, type:String
  field :host, type:String
  field :port, type:String
  field :enabled, type:Boolean
end
