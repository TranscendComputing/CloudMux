require 'sinatra'

class NewsEventApiApp < ApiBase
  get '/' do
    per_page = (params[:per_page] || 1000).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    news_events = NewsEvent.all
    count = NewsEvent.count
    query = Query.new(count, page, offset, per_page)
    news_events_query = NewsEventQuery.new(query, news_events).extend(NewsEventQueryRepresenter)
    [OK, news_events_query.to_json]
  end

  post '/' do
    new_news_event = NewsEvent.new.extend(UpdateNewsEventRepresenter)
    new_news_event.from_json(request.body.read)
    if new_news_event.valid?
      new_news_event.save!
      # refresh without the Update representer, so that we don't serialize private data back
      news_event = NewsEvent.find(new_news_event.id).extend(NewsEventRepresenter)
      [CREATED, news_event.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_news_event.errors.full_messages.join(";")}"
      message.validation_errors = new_news_event.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end
  
  put '/:id' do
    update_news_event = NewsEvent.find(params[:id])
    update_news_event.extend(UpdateNewsEventRepresenter)
    update_news_event.from_json(request.body.read)
    if update_news_event.valid?
      update_news_event.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      news_event = NewsEvent.find(update_news_event.id).extend(NewsEventRepresenter)
      [OK, news_event.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_news_event.errors.full_messages.join(";")}"
      message.validation_errors = update_news_event.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  delete '/:id' do
	  news_event = NewsEvent.find(params[:id])
	  news_event.delete
	  [OK]
  end
end
