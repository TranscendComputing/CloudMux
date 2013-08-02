require 'sinatra'
require 'redcarpet'

#
# Serves up API documentation for a specific category and service
#
class RootApp < Sinatra::Base

  set :public_folder, File.join(File.dirname(__FILE__), '..', 'public')

  get '/' do 
    redirect '/docs'
  end

  get '/docs' do
    send_file(File.join('docs', 'index.html'), {:type=>"html"})
  end

  # Routes for Swagger UI to gather web resources
  get %r{([^.]+).json} do |file|
    puts "Matched regex for #{file}."
    send_file(File.join('docs', "#{file}.json"), {:type=>"json"})
  end

  get '/css/:file' do
    send_file(File.join('docs', 'css', params[:file]), {:type=>"css"})
  end

  get '/lib/:file' do
    send_file(File.join('docs', 'lib', params[:file]), {:type=>"js"})
  end

  get '/doc/?' do
    erb :"doc/index",  :layout=>:"doc/layout"
  end

  get '/doc/:category/:version/:service' do
    erb :"doc/show", :layout=>:"doc/layout", :locals => { :doc => markdown(:"../../api-docs/#{params[:category]}/#{params[:version]}/#{params[:service]}") }
  end
end
