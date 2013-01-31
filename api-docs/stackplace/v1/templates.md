# StackPlace Templates API

## GET /stackplace/v1/templates/:id.json

Returns a JSON representation of the details about a registered template. Note that this API does not return the raw JSON of the template. 

CURL:
    curl -v http://api.stackplace.com/stackplace/v1/templates/4f299c52668c670001000001.json

#### Example Request:

    GET /stackplace/v1/templates/4f299c52668c670001000001.json HTTP/1.1
    Host: api.stackplace.com
    Accept: application/json

#### Response:

    HTTP/1.1 200 OK
    Content-Type: application/json;charset=utf-8
    Server: thin 1.3.1 codename Triple Espresso
    X-Frame-Options: sameorigin
    X-Xss-Protection: 1; mode=block
    Content-Length: 138
    Connection: keep-alive
     
    {
       "template":
        {
          "id":"4f299c52668c670001000001",
          "name":"Rails Multi-AZ (Jan 2012)",
          "template_type":"cloud_formation",
          "import_source":"file"}
    }

## GET /stackplace/v1/templates/:id/raw

Returns the raw JSON for a registered template.

CURL:
    curl -v http://api.stackplace.com/stackplace/v1/templates/4f299c52668c670001000001/raw

#### Example Request:

    GET /stackplace/v1/templates/4f299c52668c670001000001/raw HTTP/1.1
    User-Agent: curl/7.21.0 (x86_64-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18
    Host: api.stackplace.com
    Accept: application/json
     
#### Response:

    HTTP/1.1 200 OK
    Content-Type: application/json;charset=utf-8
    Server: thin 1.3.1 codename Triple Espresso
    X-Frame-Options: sameorigin
    X-Xss-Protection: 1; mode=block
    Content-Length: 12092
    Connection: keep-alive

    {
      "AWSTemplateFormatVersion" : "2010-09-09",
      "Description" : "....",
      "Parameters" : { ... }
      ...
    }

