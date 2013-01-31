## POST /stackstudio/v1/projects/:project_id/elements

Creates a new element for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 201 - Element was created. Response body will contain the JSON with the element details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/elements HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"element":{"name":"My Element","group_name":"My Group","element_type":"Element::Type","properties":{}}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"element":{"id":"4f8ebd0bbe8a7c039e000006","name":"My Element","group_name":"My Group","element_type":"Element::Type","properties":{}}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## POST /stackstudio/v1/projects/:project_id/elements/import

Imports a list of elements in bulk, reducing the number of HTTP requests required to create a new project from an initial template.  The returned payload is an ordered list of results containing the ID of the stored element (on success) and the status ('success' or 'failed').

__Note:__ The caller is currently responsible for ensuring the models are valid, as this API validates the incoming element models before saving, but does not return any validation errors. 

### Arguments

* project_id - the project's id

### Response Status Codes:

* 201 - Elements were created. 

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/elements/import HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"elements":[{"element":{"name":"My Element","group_name":"My Group","element_type":"Element::Type","properties":{}}},{"element":{"name":"My Element","group_name":"My Group","element_type":"Element::Type","properties":{}}},...]}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"import_results":{"results":[["4f9ab1e4be8a7c1d130003dd","success"],["4f9ab1e4be8a7c1d130003de","success"], ...]}}

## PUT /stackstudio/v1/projects/:project_id/elements/:element_id

Updates an existing element for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 200 - Element was updated. Response body will contain the JSON with the element details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/elements/4f8ebcb1be8a7c039e000005 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"element":{"name":"My Element 2","group_name":"My Group 2","element_type":"Element::Type","properties":{}}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"element":{"id":"4f8ebcb1be8a7c039e000005","name":"My Element 2","group_name":"My Group 2","element_type":"Element::Type","properties":{}}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## DELETE /stackstudio/v1/projects/:project_id/elements/:element_id

Deletes an existing element for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 200 - Element was deleted
* 404 - Project, version, or element not found

### Example Request:

    DELETE /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/elements/4f8ebcb1be8a7c039e000005 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso


