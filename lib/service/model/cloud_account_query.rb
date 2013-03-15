class CloudAccountQuery
  attr_accessor :query, :cloud_accounts

  def initialize(query=nil, cloud_accounts=nil)
    @query = query
    @cloud_accounts = cloud_accounts || Array.new
  end
end
