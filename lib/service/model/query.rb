class Query
  attr_accessor :total, :page, :offset, :per_page, :links

  def initialize(total=nil, page=nil, offset=nil, per_page=nil)
    @total = total
    @page = page
    @offset = offset
    @per_page = per_page
    self.links = Array.new
  end
end
