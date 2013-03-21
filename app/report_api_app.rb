require 'sinatra'

class ReportApiApp < ApiBase
  get '/accounts' do
    results = []
    # in the future, we may want to use Mongo's MapReduce capability
    # to build the report and store it into a collection. For now,
    # we'll just use mongoid
    # TODO: add batch support when the number of accounts gets large
    Account.find(:all).each do |account|
      results << account.stats
    end
    report = Struct.new(:results).new.extend(ReportRepresenter)
    report.results = results
    [OK, report.to_json]
  end
end
