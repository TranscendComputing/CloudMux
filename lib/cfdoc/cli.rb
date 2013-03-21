class CFDoc::CLI
  def self.run(target, options)
    # open the local or remote file
    io = open(target)

    # scan the file and build an object model
    parser = CFDoc::Parser::CFParser.new
    template = parser.scan(io)

    # generate the output
    t_presenter = CFDoc::Presenter::StackTemplatePresenter.new
    puts t_presenter.render_inspect(template)

  end
end
