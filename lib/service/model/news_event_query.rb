class NewsEventQuery
  attr_accessor :query, :news_events

  def initialize(query=nil, news_events=nil)
    @query = query
    @news_events = news_events || Array.new
  end

end
