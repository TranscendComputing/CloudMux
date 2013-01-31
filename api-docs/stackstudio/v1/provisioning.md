# StackStudio Provisioning API

Manages the details about a provisioned project. Currently this API only stores and retrieves details, but in the future it will also add support for actual cloud provisioning. 

A provisioned version maps to a specific project, version, and environment. It is given a name (e.g. "Demo" or "Production) to distinguish it from other provisioned stacks of the same version and environment. 

Note: A summary of the available provisioned versions for a project are now provided within the project details API. 

## POST /stackstudio/v1/provisioning/:project_id

Creates a new provisioned stack for a project

### Response Status Codes:

* 201 - ProvisionedVersion was created. Response body will contain the JSON with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded
    
    {"provisioned_version":{"stack_name":"Demo","version":"1.0.1","environment":"Production"}}


### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"provisioned_version":{"id":"4f95831bbe8a7c4115000001","stack_name":"Demo","version":"1.0.1","environment":"Production","provisioned_instances":[]}}
### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## GET /stackstudio/v1/provisioning/:id.json

Retrieves a representation of a provisioned version, including instance details

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /stackstudio/v1/projects/4f95831bbe8a7c4115000001.json HTTP/1.1
    Connection: close
    Host: api.stackplace.com

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"provisioned_version":{"id":"4f95831bbe8a7c4115000001","stack_name":"Demo","version":"1.0.1","environment":"Production","provisioned_instances":[]}}


## POST /stackstudio/v1/provisioning/:id/instances

Stores one or more provisioned instance details for a provisioned version

### Response Status Codes:

* 200 - Operation succeeded. Response is a JSON payload with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/provisioning/4f95831bbe8a7c4115000001/instances HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"instances":[{"provisioned_instance":{"instance_type":"EC2","instance_id":"abcdef","resource_id":"the_resource_id","properties":{}}}]}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"provisioned_version":{"id":"4f95831bbe8a7c4115000001","stack_name":"Demo","version":"1.0.1","environment":"Production","provisioned_instances":[{"provisioned_instance":{"id":"4f9584d7be8a7c4880000001","instance_type":"EC2","instance_id":"abcdef","resource_id":"the_resource_id","properties":{}}}]}}


## DELETE /stackstudio/v1/provisioning/:id/instances/:instance_id

Removes a provisioned instance from a provisioned version

### Response Status Codes:

* 200 - Operation succeeded. Updated details for the provisioned version included
* 404 - Provisioned Instance not found

### Example Request:

    DELETE provisioning/4f95831bbe8a7c4115000001/instances/4f9584eebe8a7c4880000002 HTTP/1.1
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

    {"provisioned_version":{"id":"4f95831bbe8a7c4115000001","stack_name":"Demo","version":"1.0.1","environment":"Production","provisioned_instances":[{"provisioned_instance":{"id":"4f9584d7be8a7c4880000001","instance_type":"EC2","instance_id":"abcdef","resource_id":"the_resource_id","properties":{}}}]}}

## DELETE /stackstudio/v1/provisioning/:id

Permanently removes a provisioned version

### Response Status Codes:

* 200 - Operation succeeded.
* 404 - Provisioned Instance not found

### Example Request:

    DELETE provisioning/4f95831bbe8a7c4115000001 HTTP/1.1
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
