require 'sinatra'

class StackApiApp < ApiBase
  get '/' do
    per_page = (params[:per_page] || 20).to_i
    per_page = 100 if per_page > 100 # limit
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    conditions = { public:true }
    categories = (params[:categories] || "").split(",")
    if !categories.empty?
      conditions[:category_id.in] = categories
    end
    stacks = Stack.where(conditions).order_by([:name, :asc]).limit(per_page).offset(offset)
    count = Stack.where(conditions).count
    query = Query.new(count, page, offset, per_page)
    # Note: may need to add capture of other parameters, delete page, and rebuild (ala will_paginate and others)
    query.links << Link.new('next', "#{ServiceConfig.base_url}#{request.env["REQUEST_PATH"]}?page=#{page+1}&categories=#{params[:categories]}") unless (offset + per_page) >= count
    query.links << Link.new('prev', "#{ServiceConfig.base_url}#{request.env["REQUEST_PATH"]}?page=#{page-1}&categories=#{params[:categories]}") unless (page == 1)
    stack_query = StackQuery.new(query, stacks).extend(StackQueryRepresenter)
    [OK, stack_query.to_json]
  end

  get '/:id.json' do
    stack = Stack.find_by_permalink(params[:id]) || Stack.find(params[:id])
    stack.extend(StackRepresenter)
    [OK, stack.to_json]
  end

  get '/:user/:permalink.json' do
    stack = Stack.find_by_permalink("#{params[:user]}/#{params[:permalink]}")
    if stack.nil?
      return [NOT_FOUND]
    end

    stack.extend(StackRepresenter)
    [OK, stack.to_json]
  end

  post '/' do
    create_stack = CreateStack.new.extend(CreateStackRepresenter)
    create_stack.from_json(request.body.read)
    if create_stack.valid?
      new_stack = create_stack.to_stack
      new_stack.save!
      if create_stack.template_id
        # attach the template to the stack, claiming it
        template = Template.find(create_stack.template_id)
        template.stack = new_stack
        template.save!
        # update the stack's resource groups for the associated
        # templates. This may be moved to an async process or a model
        # hook, but for now it will be triggered here in case we
        # decide to allow the user to select the groups from a list of
        # recommended ones during the stack creation process
        new_stack.update_resource_groups!
      end
      new_stack.extend(StackRepresenter)
      [CREATED, new_stack.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{create_stack.errors.full_messages.join(";")}"
      message.validation_errors = create_stack.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_stack = Stack.find(params[:id]).extend(UpdateStackRepresenter)
    update_stack.from_json(request.body.read)
    if update_stack.valid?
      update_stack.save!
      stack = Stack.find(update_stack.id).extend(StackRepresenter)
      [OK, stack.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_stack.errors.full_messages.join(";")}"
      message.validation_errors = update_stack.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  # Note: this currently only updates the counter and returns the
  # stack's default JSON representation. Future implementation may
  # generate a zip and return the URL.
  get '/:user/:permalink/download/:stack_version' do
    stack = Stack.find_by_permalink("#{params[:user]}/#{params[:permalink]}")
    stack.downloaded!
    stack.extend(StackRepresenter)
    [OK, stack.to_json]
  end

end
