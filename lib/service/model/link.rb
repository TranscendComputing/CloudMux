class Link
  attr_accessor :rel, :href

  def initialize(rel=nil, href=nil)
    @rel = rel
    @href = href
  end
end
