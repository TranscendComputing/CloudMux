require 'sinatra'
require 'redcarpet'

#
# Serves up API documentation for a specific category and service
#
class RootApp < Sinatra::Base

  set :public_folder, File.join(File.dirname(__FILE__), '..', 'public')

  get '/' do 
    "Home"
  end

  get '/doc/?' do
    erb :"doc/index",  :layout=>:"doc/layout"
  end

  get '/doc/:category/:version/:service' do
    erb :"doc/show", :layout=>:"doc/layout", :locals => { :doc => markdown(:"../../api-docs/#{params[:category]}/#{params[:version]}/#{params[:service]}") }
  end
end
