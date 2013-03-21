# StackStudio NewsEvents API

Lookup news events

## GET /stackstudio/v1/news_events

Returns a paginated list of events and news

### Arguments

* page - The page number of the query. Defaults to 1 if not provided
* per_page - The number of results per page

### Response Status Codes:

* 200 - Query successful

### Example Request:

    GET /stackstudio/v1/news_events?page=1 HTTP/1.1
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

    {"query":{"total":1,"page":1,"offset":0,"per_page":1000,"links":[]},"news_events":[{"news_event":{"id":"4f7daff2681151a840000001","description":"StackPlace finally launches.","url":"https://www.transcendcomputing.com","posted":"2012-08-06 16:11:01 -0500","source":"TranscendComputing"}}]}

### Error Response:
None

## POST /stackstudio/v1/news_events/

Creates a news event in the system

### Response Status Codes:

* 201 - NewsEvent was created. Response body will contain the JSON with the event details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/news_events HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"news_event":{"description":"StackPlace finally launches.", "url":"https://www.transcendcomputing.com","posted":"2012-08-06 16:11:01 -0500","source":"TranscendComputing"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"news_event":{"id":"4f7daff2681151a840000001","description":"StackPlace finally launches.","url":"https://www.transcendcomputing.com","posted":"2012-08-06 16:11:01 -0500","source":"TranscendComputing"}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Url can't be blank","validation_errors":{"url":["can't be blank"]}}}
    
## PUT /stackstudio/v1/news_events/:id
Updates an existing news event with new details.

__NOTE:__ All details must be sent on the update, otherwise fields with missing values will be set to an empty value. NO INCREMENTAL UPDATES ARE CURRENTLY SUPPORTED.

### Response Status Codes:

* 200 - Operation succeeded. Response is a JSON payload with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/news_event/4f84708bbe8a7c3355000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"news_event":{"description":"Transcend Launches.","url":"https://www.transcendcomputing.com","source":"TranscendComputing","posted":"2012-08-06 16:11:01 -0500"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"news_event":{"id":"4f7daff2681151a840000001","description":"Transcend Launches.","url":"https://www.transcendcomputing.com","source":"TranscendComputing","posted":"2012-08-06 16:11:01 -0500"}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"description":["can't be blank"]}}}
    