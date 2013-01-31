class Node
  # Mongoid Mappings
  include Mongoid::Document

  embedded_in :project_version

  field :name, type:String
  field :x, type:String
  field :y, type:String
  field :view, type:String
  field :element_id, type:String
  field :properties, type:String

  embeds_many :node_links

  def has_link?(link)
    node_links.each do |nl|
      if nl.source_id == link.source_id and nl.target_id == link.target_id
        return true
      end
    end
    return false
  end

  def add_link!(node_link)
    if !has_link?(node_link)
      self.node_links << node_link
    end
  end
end
