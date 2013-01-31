module ImportTemplateRepresenter
  include Roar::Representer::JSON

  property :name
  property :import_source
  property :json_base64
end
