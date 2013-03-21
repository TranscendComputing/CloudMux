class ImportResults
  SUCCESS = 'success'
  FAILED = 'failed'

  attr_accessor :results

  def initialize
    @results = []
  end

  def add_result(id, status)
    @results << [id, status]
  end
end
