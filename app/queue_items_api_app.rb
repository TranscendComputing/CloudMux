require 'sinatra'
class QueueItemsApiApp < ApiBase

  get '/' do
    queue = QueueItem.all.entries
    [OK, queue.to_json]
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
      print data
      qitem = QueueItem.new()
      qitem.account_id = params[:account_id]
      qitem.cred_id = data['credential_id']
      qitem.data = data['stack_name']
      qitem.action = "%s:%s" % [data['host_name'] , data['jobs'].join(' ')]
      qitem.save!
      [OK, qitem.to_json]
    end
  end

  put '/' do
    data = body_to_json(request)
    if (data.nil?)
      error = Error.new.extend(ErrorRepresenter)
      error.message = "Must give attributes for new QueueItem"
      [BAD_REQUEST, error.to_json]
    else
      qitem = QueueItem.new()
      # [XXX] needs to support other types of queue actions
      qitem.update_attributes! data
      # qitem.caller =  
      [OK, qitem.to_json]
    end
  end

  put '/:id' do 
    data = body_to_json(request)
    if (data.nil?)
      error = Error.new.extend(ErrorRepresenter)
      error.message = "Must give attributes to update QueueItem"
      [BAD_REQUEST, error.to_json]
    else
      qitem = QueueItem.find(params[:id])
      qitem.update_attributes! data
      [OK, qitem.to_json]
    end
  end

end
