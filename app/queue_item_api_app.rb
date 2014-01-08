require 'sinatra'
class QueueItemApiApp < ApiBase

  get '/:id.json' do
    qitem = QueueItem.where(id:params[:id]).first
    if qitem.nil?
      [NOT_FOUND, {:message=>"Could not find QueueItem"}.to_json]
    else
      [OK, qitem.to_json]
    end
  end

  get '/:id' do
    qitem = QueueItem.where(id:params[:id]).first
    if qitem.nil?
      [NOT_FOUND, {:message=>"Could not find QueueItem"}.to_json]
    else
      [OK, qitem.to_json]
    end
  end

  post '/' do
    data = body_to_json(request)
    if (data.nil?)
      error = Error.new.extend(ErrorRepresenter)
      error.message = "Must give attributes for new QueueItem"
      [BAD_REQUEST, error.to_json]
    else
      qitem = QueueItem.new()
      qitem.account_id = params[:account_id]
      qitem.cred_id = data['credential_id']
      qitem.data = data['stack_name']
      unless data.has_key? 'action'
        qitem.action = "%s:%s" % [data['host_name'] , data['jobs'].join(' ')]
      else
        qitem.action = data['action']
      end
      qitem.save!
      [CREATED, qitem.to_json]
    end
  end
end
