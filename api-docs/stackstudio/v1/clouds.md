# StackStudio Clouds API

Lookup clouds that are publicly available for use in provisioning

## GET /stackstudio/v1/clouds

Returns a paginated list of public clouds registered.

### Arguments

* page - The page number of the query. Defaults to 1 if not provided
* per_page - The number of results per page

### Response Status Codes:

* 200 - Query successful

### Example Request:

    GET /stackstudio/v1/clouds?page=1 HTTP/1.1
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

    {"query":{"total":1,"page":1,"offset":0,"per_page":1000,"links":[]},"clouds":[{"cloud":{"id":"4f7daff2681151a840000001","name":"Cloud 1","permalink":"cloud-1","public":true,"cloud_services":[],"cloud_mappings":[]}}]}

### Error Response:
None

## POST /stackstudio/v1/clouds/

Creates a new cloud in the system

### Response Status Codes:

* 201 - Cloud was created. Response body will contain the JSON with the cloud details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/clouds HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud":{"name":"Cloud 1"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"cloud":{"id":"4f7daff2681151a840000001","name":"Cloud 1","permalink":"cloud-1","public":true,"cloud_services":[],"cloud_mappings":[]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## GET /stackstudio/v1/clouds/:id.json
Retrieves a representation of an cloud, including associated details, such as cloud services and mappings.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /stackstudio/v1/clouds/4f62355abe8a7c148d000004.json HTTP/1.1
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

    {"cloud":{"id":"4f7daff2681151a840000001","name":"Cloud 1","permalink":"cloud-1","public":true,"cloud_services":[],"cloud_mappings":[]}}

### Error Response:
None


## PUT /stackstudio/v1/clouds/:id
Updates an existing cloud with new details.

__NOTE:__ All details must be sent on the update, otherwise fields with missing values will be set to an empty value. NO INCREMENTAL UPDATES ARE CURRENTLY SUPPORTED.

### Response Status Codes:

* 200 - Authentication succeeded. Response is a JSON payload with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/clouds/4f62355abe8a7c148d000004 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud":{"name":"Cloud 2"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"cloud":{"id":"4f7daff2681151a840000001","name":"Cloud 2","permalink":"cloud-2","public":true,"cloud_services":[],"cloud_mappings":[]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}


## POST /stackstudio/v1/clouds/:id/services

Registers a new cloud service for a cloud.

### Arguments

* id - the cloud's id

### Response Status Codes:

* 200 - Service added

### Example Request:

    POST /stackstudio/v1/clouds/4f7daff2681151a840000001/services HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_service":{"service_type":"My Type"}}

### Response:

The updated cloud payload

## DELETE /stackstudio/v1/clouds/:id/services/:service_id

Removes a cloud service from a cloud.

### Arguments

* id - the cloud's id
* service\_id - the service id owned by the cloud

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/clouds/4f7daff2681151a840000001/services/4f7dcc04681151b0a5000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated cloud payload

## POST /stackstudio/v1/clouds/:id/mappings

Registers a new cloud mapping for a cloud.

### Arguments

* id - the cloud's id

### Response Status Codes:

* 200 - Mapping added

### Example Request:

    POST /stackstudio/v1/clouds/4f7daff2681151a840000001/mappings HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_mapping":{"name":"My Mapping","mapping_type":"My Mapping Type","properties":{},"mapping_entries":[]}}

### Response:

The updated cloud payload

## DELETE /stackstudio/v1/clouds/:id/mappings/:mapping_id

Removes a cloud mapping from a cloud.

### Arguments

* id - the cloud's id
* mapping\_id - the mapping id owned by the cloud

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/clouds/4f7daff2681151a840000001/mappings HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated cloud payload
