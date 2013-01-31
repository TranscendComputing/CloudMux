## POST /stackstudio/v1/projects/:project_id/nodes

Creates a new node for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 201 - Node was created. Response body will contain the JSON with the node details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/nodes HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"node":{"name":"My Node","x":"2","y":"4","view":"design","properties":{}}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"node":{"id":"4f8ebec4be8a7c039e000007","name":"My Node","x":"2","y":"4","view":"design","properties":{}}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## POST /stackstudio/v1/projects/:project_id/nodes/import

Imports a list of nodes in bulk, reducing the number of HTTP requests required to create a new project from an initial template. The returned payload is an ordered list of results containing the ID of the stored node (on success) and the status ('success' or 'failed').

__Note:__ The caller is currently responsible for ensuring the models are valid, as this API validates the incoming node models before saving, but does not return any validation errors. 

### Arguments

* project_id - the project's id

### Response Status Codes:

* 201 - Nodes were created. 

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/nodes/import HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"nodes":[{"node":{"name":"My Node","x":"2","y":"4","view":"design","properties":{}}}, {"node":{"name":"My Node","x":"2","y":"4","view":"design","properties":{}}},...]}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"import_results":{"results":[["4f9ab1e4be8a7c1d130003dd","success"],["4f9ab1e4be8a7c1d130003de","success"], ...]}}
    
## PUT /stackstudio/v1/projects/:project_id/nodes/:node_id

Updates an existing node for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 200 - Node was updated. Response body will contain the JSON with the node details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/nodes/4f8ebec4be8a7c039e000007 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"node":{"name":"My Node 2","x":"2","y":"4","view":"design","properties":{}}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"node":{"id":"4f8ebec4be8a7c039e000007","name":"My Node 2","x":"2","y":"4","view":"design","properties":{}}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## DELETE /stackstudio/v1/projects/:project_id/nodes/:node_id

Deletes an existing node for the current project version

### Arguments

* project_id - the project's id

### Response Status Codes:

* 200 - Node was deleted
* 404 - Project, version, or node not found

### Example Request:

    DELETE /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/nodes/4f8ebec4be8a7c039e000007 HTTP/1.1
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


## POST /stackstudio/v1/projects/:project_id/nodes/link

Creates a new link between nodes, assigning the ownership of the link to the source node. Note that the same link between nodes will be ignored, preventing duplicate entries. 

### Arguments

* project_id - the project's id

### Response Status Codes:

* 201 - Node link was created. Response body will contain the JSON with the source node details

### Example Request:

    POST /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/nodes/link HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"node_link":{"source_id":"4f8ebec4be8a7c039e000007","target_id":"4f8ec174be8a7c07ae000001"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"node":{"id":"4f8ebec4be8a7c039e000007","name":"My Node 2","x":"2","y":"4","view":"design","properties":{},"node_links":[{"node_link":{"source_id":"4f8ebec4be8a7c039e000007","target_id":"4f8ec174be8a7c07ae000001"}}]}}


