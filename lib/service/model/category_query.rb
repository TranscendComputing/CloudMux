class CategoryQuery
  attr_accessor :query, :categories

  def initialize(query=nil, categories=nil)
    @query = query
    @categories = categories || Array.new
  end

end
