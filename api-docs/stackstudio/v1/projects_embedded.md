## POST /stackstudio/v1/projects/:project_id/embedded_projects

Links a project as an embedded project to the given project

### Arguments

* project_id - the project's id that will own the embedded project

### Response Status Codes:

* 201 - Embedded project was linked. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/embedded_projects HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"embedded_project":{"id":"4f973276be8a7c174e000001","variants":[]}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"embedded_project":{"id":"4f9736cbbe8a7c18a6000002","embedded_project_id":"4f973262be8a7c244f000002","embedded_project_name":"My Embedded","variants":[]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## DELETE /stackstudio/v1/projects/:project_id/embedded_projects/:embedded_project_id

Deletes an embedded project from the current project version

### Arguments

* project_id - the project's id
* embedded_project_id - the ID of the embedded project to remove

### Response Status Codes:

* 200 - Embedded project was deleted
* 404 - Project or embedded project not found

### Example Request:

    DELETE /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/embedded_projects/4f9736cbbe8a7c18a6000002 HTTP/1.1
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

## POST /stackstudio/v1/projects/:project_id/embedded_projects/:embedded_project_id/variants

Creates a new environment variant for an embedded project within the current project version

### Arguments

* project_id - the project's id
* embedded_project_id - the embedded project id

### Response Status Codes:

* 201 - Variant was created. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/embedded_projects/4f9736cbbe8a7c18a6000002/variants HTTP/1.1
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

## PUT /stackstudio/v1/projects/:project_id/embedded_projects/:embedded_project_id/variants/:variant_id

Updates an existing environment variant for an embedded project within the current project version

### Arguments

* project_id - the project's id
* embedded_project_id - the embedded project id
* variant_id - the ID of the variant to update

### Response Status Codes:

* 200 - Variant was updated. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/embedded_projects/4f9736cbbe8a7c18a6000002/variants/4f96c477be8a7c244f000001 HTTP/1.1
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

## DELETE /stackstudio/v1/projects/:project_id/embedded_projects/:embedded_project_id/variants/:variant_id

Deletes an existing variant an embedded project within the current project version

### Arguments

* project_id - the project's id
* embedded_project_id - the embedded project id
* variant_id - the ID of the variant

### Response Status Codes:

* 200 - Variant was deleted
* 404 - Project, Embedded Project, or Variant not found

### Example Request:

    DELETE /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/embedded_projects/4f9736cbbe8a7c18a6000002/variants/4f96c477be8a7c244f000001 HTTP/1.1
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

