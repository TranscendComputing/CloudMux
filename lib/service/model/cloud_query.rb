class CloudQuery
  attr_accessor :query, :clouds

  def initialize(query=nil, clouds=nil)
    @query = query
    @clouds = clouds || Array.new
  end

end
