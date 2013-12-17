require 'sinatra/base'

class FakeAnsible < Sinatra::Base
  post '/api/v1/authtoken' do
    json_response (200, 'ansible/authtoken_ok.json' )
  end

  private

  def json_response(response_code, filename)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__),'/fixtures/'+filename,'rb').read
  end
end
