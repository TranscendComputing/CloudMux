require 'sinatra'

class TemplateApiApp < ApiBase

  # Create new template
  #
  post '/' do
    import = ImportTemplate.new.extend(ImportTemplateRepresenter)
    import.from_json(request.body.read)
    template = Template.new(:import_source=>import.import_source, :name=>import.name, :template_type=>Template::CLOUD_FORMATION, :raw_json=>import.json)
    if template.valid?
      template.extend(TemplateRepresenter)
      template.save!
      [CREATED, template.to_json]
    else
      message = Error.new.extend(ErrorRepresenter)
      message.message = "#{template.errors.full_messages.join(";")}"
      message.validation_errors = template.errors.to_hash
      [BAD_REQUEST, message.to_json]
    end

  end

  # List templates
  #
  get '/' do
    # TODO: pagination
    # TODO: filtering based on owner, self, public vs. private?
    results = []
    response = { :templates=> results}
    templates = Template.all
    response[:templates] = templates.map do |t|
      t.extend(TemplateRepresenter)
      results << t.to_json
    end
    # TODO: FIX to work with Roar better
    "{templates:[#{results.join("\n")}]}"
  end

  # Template details
  #
  get '/:id.json' do
    template = Template.find(params[:id])
    template.extend(TemplateRepresenter)
    return template.to_json
  end

  get '/:id.html' do
    content_type 'text/html', :charset => 'utf-8'
    template = Template.find(params[:id])
    parser = CFDoc::Parser::CFParser.new
    stack_template = parser.scan(template.raw_json)
    t_presenter = CFDoc::Presenter::StackTemplatePresenter.new
    t_presenter.render_html(stack_template)
  end

  # Template's raw JSON
  #
  get '/:id/raw' do
    template = Template.find(params[:id])
    template.raw_json # raw source
  end

end
