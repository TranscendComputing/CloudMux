require 'sinatra'

class CategoryApiApp < ApiBase
  get '/' do
    per_page = (params[:per_page] || 1000).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1)*per_page
    categories = Category.all
    count = Category.count
    query = Query.new(count, page, offset, per_page)
    category_query = CategoryQuery.new(query, categories).extend(CategoryQueryRepresenter)
    [OK, category_query.to_json]
  end

  get '/:id.json' do
    category = Category.find_by_permalink(params[:id]) || Category.find(params[:id])
    category.extend(CategoryRepresenter)
    category.to_json
  end

  post '/' do
    new_category = Category.new.extend(UpdateCategoryRepresenter)
    new_category.from_json(request.body.read)
    if new_category.valid?
      new_category.save!
      # refresh without the Update representer, so that we don't serialize private data back
      category = Category.find(new_category.id).extend(CategoryRepresenter)
      [CREATED, category.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{new_category.errors.full_messages.join(";")}"
      message.validation_errors = new_category.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end

  put '/:id' do
    update_category = Category.find(params[:id])
    update_category.extend(UpdateCategoryRepresenter)
    update_category.from_json(request.body.read)
    if update_category.valid?
      update_category.save!
      # refresh without the Update representer, so that we don't serialize the password data back across
      category = Category.find(update_category.id).extend(CategoryRepresenter)
      [OK, category.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{update_category.errors.full_messages.join(";")}"
      message.validation_errors = update_category.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end
  end
end
