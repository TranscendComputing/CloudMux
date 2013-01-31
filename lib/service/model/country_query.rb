class CountryQuery
  attr_accessor :query, :countries

  def initialize(query=nil, countries=nil)
    @query = query
    @countries = countries || Array.new
  end
end
