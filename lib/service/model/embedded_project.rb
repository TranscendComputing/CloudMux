#
# Tracks the link between a top-level project and an embedded project
#
class EmbeddedProject

  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :project_version
  belongs_to :embedded_project, :class_name=>"Project"

  # for tracking environment variants for the embedded project, compared to its baseline
  embeds_many :variants, :as=>:variantable

  def embedded_project_name
    return (embedded_project.nil? ? nil : embedded_project.name)
  end

  def find_variant(variant_id)
    variants.select { |v| v.id.to_s == variant_id.to_s }.first
  end

  def remove_variant_for!(environment)
    found = variants.select { |v| v.environment == environment }.first
    found.delete if found
  end
end
