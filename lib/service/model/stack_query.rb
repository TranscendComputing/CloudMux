class StackQuery
  attr_accessor :query, :stacks

  def initialize(query=nil, stacks=nil)
    @query = query
    @stacks = stacks || Array.new
  end

end
