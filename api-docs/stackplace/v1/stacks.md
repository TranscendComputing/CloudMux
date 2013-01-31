# StackPlace Stacks API

This is the primary entry point for public access to the StackPlace REST API.

Stacks are owned by one Account and may contain one or more Templates. Puppet/Chef scripts, diagrams, documents, and artifacts may be added to Stacks in the future to compose a complete architecture topology.

## GET /stackplace/v1/stacks

Returns a paginated list of public stacks registered at StackPlace. 

The response is contains a query element that contains details about the query, such as the total count of results, the current page number, offset (starting index), and the number of results per page provided. The query element also contains next/prev links, when available, for navigating the pagination support without requiring the client to compute the URL.

Stacks returned from the query include basic template details, including an ID and name, for retrieval using the [StackPlace Template API](/doc/stackplace/v1/templates)

### Arguments

* page - The page number of the query. Defaults to 1 if not provided
* per_page - The number of results per page, up to a maximum of 100
* categories - (optional) A csv list of category IDs (not permalinks) to filter on

### Response Status Codes:
 
* 200 - Query successful

### Example Request:

    GET /stackplace/v1/stacks?page=1&per_page=2 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
     
### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 559
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso
     
    {
       "query":{"total":12,"page":1,"offset":0,"per_page":2, "links":[{"rel":"next","href":"http://localhost:9292/stackplace/v1/stacks?page=2"}]},
       "stacks":[
           {"stack":{"id":"4f396f96be8a7c2f95000001","name":"James Test 1","description":"Testing 1",
             "permalink":"test/james-test-1","public":true,"created_at":"2012-02-13T14:16:22-06:00","updated_at":"2012-02-13T14:16:22-06:00",
             "account": {"id":"4f3be152be8a7c4601000003","login":"test"},
             "category": {"id":"4f3be152be8a7c4601000004","name":"My Category", "permalink":"my-category","description":"My description"},
             "templates":[]}},
           {"stack":{"id":"4f396fbcbe8a7c2f95000002","name":"James Test 2","description":"Testing 1",
             "permalink":"test/james-test-2","public":true,"created_at":"2012-02-13T14:17:00-06:00","updated_at":"2012-02-13T14:17:00-06:00",
             "account": {"id":"4f3be152be8a7c4601000003","login":"test"},
             "category": {"id":"4f3be152be8a7c4601000004","name":"My Category", "permalink":"my-category","description":"My description"},
            "templates":[
             {\"template\":{\"id\":\"4f3559a6be8a7c1a39000001\",\"name\":\"Test\",\"template_type\":\"cloud_formation\"}}
            ]}
           }
         ]
     }

### Error Response:
None

## GET /stackplace/v1/stacks/:id.json

Retrieves the details of a Stack by permalink or id. Details include: the account that owns the stack, any associated templates and their template details for retrieval using the [StackPlace Template API](/doc/stackplace/v1/templates), and the created/updated dates for the stack

### Response Status Codes:
 
* 200 - Query successful
* 404 - Not found

### Example Request:

    GET /stackplace/v1/stacks/4f39721ebe8a7c389b000001.json HTTP/1.1
    Connection: close
    Host: api.stackplace.com

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 296
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {
      "stack":
      {
        "id":"4f39721ebe8a7c389b000001","name":"James Test 1","description":"Testing 1",
        "permalink":"test/james-test-1","public":true,"created_at":"2012-02-13T14:27:10-06:00","updated_at":"2012-02-13T14:27:10-06:00",
        "account": {"id":"4f3be152be8a7c4601000003","login":"test"},
        "category": {"id":"4f3be152be8a7c4601000004","name":"My Category", "permalink":"my-category","description":"My description"},
        "templates":[
           {"template":{"id":"4f3559a6be8a7c1a39000001","name":"Test","template_type":"cloud_formation"}}
        ]
      }
     }

## POST /stackplace/v1/stacks

Creates a new public stack associated to an existing account. If a template_id is provided, the template is associated to the stack and is now considered published. Templates may only be published by one account. If a template ID is provided that has already been published, an error is returned.

### Response Status Codes:
 
* 201 - Stack was created. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackplace/v1/stacks HTTP/1.1
    Connection: close
    Host: localhost:9292
    Content-Length: 141
    Content-Type: application/x-www-form-urlencoded
     
    {"stack":{"name":"My Stack","description":"My first stack","account_id":"4f32af1ebe8a7c6ef0000001","template_id":"4f21bd99be8a7c6aa7000002","category_id":"4f21bd99be8a7c6aa7000003"}}"
     
### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 301
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {
      "stack":
       {
        "id":"4f3a76c4be8a7c37de000001","name":"My Stack","description":"My first stack",
        "permalink":"test/my-stack","public":true,"created_at":"2012-02-14T08:59:16-06:00","updated_at":"2012-02-14T08:59:16-06:00",
        "account": {"id":"4f3be152be8a7c4601000003","login":"test"},
        "category": {"id":"4f3be152be8a7c4601000004","name":"My Category", "permalink":"my-category","description":"My description"},
        "templates":[
           {"template":{"id":"4f21bd99be8a7c6aa7000002","name":"CLI test","template_type":"cloud_formation"}}
        ]
      }
    }

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso
     
    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}


## PUT /stackplace/v1/stacks/:id

Updates an existing stack with new details.

__NOTE:__ All stack details must be sent on the update, otherwise fields with missing values will be set to an empty value. NO INCREMENTAL UPDATES ARE CURRENTLY SUPPORTED.

### Response Status Codes:
 
* 200 - Authentication succeeded. Response is a JSON payload with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackplace/v1/stacks/4f3a76c4be8a7c37de000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded
     
    {"stack":{"name":"My Renamed Stack","description":"My first renamed stack"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso
     
    {
      "stack":{
         "name":"My Renamed Stack","description":"My first renamed stack",
         "permalink":"test/my-renamed-stack",
         "account": {"id":"4f3be152be8a7c4601000003","login":"test"},
         "category": {"id":"4f3be152be8a7c4601000004","name":"My Category", "permalink":"my-category","description":"My description"},
         "templates":[
           {"template":{"id":"4f21bd99be8a7c6aa7000002","name":"CLI test","template_type":"cloud_formation"}}
    }

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso
     
    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}
