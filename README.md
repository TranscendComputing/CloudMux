CloudMux
========

The CloudMux project provides a RESTful service layer for the management of multiple public/private cloud backends. The JSON-over-REST services abstract many of the details of calling specific cloud APIs. The JSON models returned are decorated with additional properties when supported by the cloud, or returned with minimal properties for a base IaaS cloud. CloudMux maintains an internal datastore with cloud definitions and cloud credentials, and makes native calls against the cloud on behalf of a user.

CloudMux currently supports the following clouds:

* â Amazon (AWS)
* â OpenStack (Essex & Folsom)

You can explore the REST API at the [API Doc browser](/docs/).

![CloudMux Architecture](/docs/CloudMuxArchitecture.png "CloudMux Architecture")


