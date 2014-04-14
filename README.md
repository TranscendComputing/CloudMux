CloudMux
========
[![Build Status](https://secure.travis-ci.org/TranscendComputing/CloudMux.png?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/TranscendComputing/CloudMux.png)][codeclimate]

[travis]: http://travis-ci.org/TranscendComputing/CloudMux
[codeclimate]: https://codeclimate.com/github/TranscendComputing/CloudMux

The CloudMux project provides a RESTful service layer for the management of multiple public/private cloud backends. The JSON-over-REST services abstract many of the details of calling specific cloud APIs. The JSON models returned are decorated with additional properties when supported by the cloud, or returned with minimal properties for a base IaaS cloud. CloudMux maintains an internal datastore with cloud definitions and cloud credentials, and makes native calls against the cloud on behalf of a user.

CloudMux currently supports the following clouds:

* Amazon (AWS)
* OpenStack (Essex & Grizzly)
* Google Compute Engine (GCE)

<!--- You can explore the REST API at the [API Doc browser](/docs/). -->

![CloudMux Architecture](https://raw2.github.com/TranscendComputing/CloudMux/master/docs/CloudMuxArchitecture.png "CloudMux Architecture")

Getting Started
---------------

1. Make sure you have ruby 1.9.2 or 1.9.3 and mongodb installed.

2. Create a ruby environment file and source with the following contents (edit your mongo user and password):

* STACK_PLACE_SERVICE_ENDPOINT=http://localhost:9292
* MONGO_URI=mongodb://MONGOUSER:MONGOPASSWORD@localhost:27017
* RACK_ENV=development
* RAILS_ENV=development
* export STACK_PLACE_SERVICE_ENDPOINT MONG_URI RACK_ENV RAILS_ENV

	`source cloudmux.env`

4. Install nokogiri dependencies on the system (below is for Ubuntu/Debian systems.  Reference [Installing Nokogiri](http://nokogiri.org/tutorials/installing_nokogiri.html) for others):

	`sudo apt-get install libxslt-dev libxml2-dev`

3. Install Gem dependencies, cd to the <tt>CloudMux</tt> directory and run (if bundler is not install run `gem install bundler`):

	`bundle install`

3. Seed mongodb, from the <tt>CloudMux</tt> directory run:

	`rake db:seed`

4. You are now ready to host CloudMux. This can simple be started from the <tt>CloudMux</tt> directory by running:

	`sh script/start_cloudmux.sh`

or you can setup through an HTTP server (e.g. Apache w/ Passenger)


	



