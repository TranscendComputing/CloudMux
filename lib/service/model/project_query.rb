class ProjectQuery
  attr_accessor :query, :projects

  def initialize(query=nil, projects=nil)
    @query = query
    @projects = projects || Array.new
  end
end
