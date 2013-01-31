module StackRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :name
  property :description
  property :support_details
  property :license_agreement
  property :image_name
  property :image_data
  property :permalink
  property :public
  property :downloads
  property :created_at
  property :updated_at
  property :account, :class=>Account, :extend => AccountSummaryRepresenter
  property :category, :class=>Category, :extend => CategorySummaryRepresenter
  collection :templates, :class=>Template, :extend => TemplateSummaryRepresenter
  collection :resource_groups
end
