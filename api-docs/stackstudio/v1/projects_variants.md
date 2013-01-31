## POST /stackstudio/v1/projects/:project_id/variants

Creates a new environment variant for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 201 - Variant was created. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/variants HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"variant":{"environment":"Dev","rule_type":"My Rule Type","rules":{}}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"variant":{"id":"4f96c477be8a7c244f000001","environment":"Dev","rule_type":"My Rule Type","rules":{}}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Environment can't be blank","validation_errors":{"environment":["can't be blank"]}}}

## PUT /stackstudio/v1/projects/:project_id/variants/:variant_id

Updates an existing environment variant for the current project version

### Arguments

* project_id - the project's id
* variant_id - the ID of the variant to update

### Response Status Codes:

* 200 - Variant was updated. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/variants/4f96c477be8a7c244f000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"variant":{"environment":"Dev","rule_type":"My Modified Rule Type","rules":{}}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"variant":{"id":"4f96c477be8a7c244f000001","environment":"Dev","rule_type":"My Modified Rule Type","rules":{}}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## DELETE /stackstudio/v1/projects/:project_id/variants/:variant_id

Deletes an existing variant for the current project version

### Arguments

* project_id - the project's id
* variant_id - the ID of the variant

### Response Status Codes:

* 200 - Variant was deleted
* 404 - Project or variant not found

### Example Request:

    DELETE /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/variants/4f96c477be8a7c244f000001 HTTP/1.1
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

