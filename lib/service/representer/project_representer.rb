module ProjectRepresenter
  include Roar::Representer::JSON

  # wrap the fields e.g. { "model_name" : { ...fields... }
  self.representation_wrap = true

  property :id
  property :status
  property :name
  property :description
  property :project_type
  property :region
  property :owner, :class=>Account, :extend=>AccountSummaryRepresenter
  property :cloud_credential, :class=>CloudCredential, :extend=>CloudCredentialRepresenter
  collection :members, :class=>Member, :extend=>MemberRepresenter
  collection :group_projects, :class=>GroupProject, :extend=>GroupProjectRepresenter
  collection :versions, :class=>Version, :extend=>VersionRepresenter
  collection :provisioned_versions, :class=>ProvisionedVersion, :extend=>ProvisionedVersionSummaryRepresenter
end
