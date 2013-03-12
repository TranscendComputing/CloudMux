# StackStudio Cloud Accounts API


## POST /stackstudio/v1/cloud_accounts/

Creates a new cloud account in the system

### Response Status Codes:

* 201 - Cloud Account was created. Response body will contain the JSON with the cloud details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/clouds HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_account":{"name":"Cloud Account 1", "cloud_id":"4f7f4ae2be8a7c052a000001", "org_id":"4f32af1ebe8a7c6ef0000001"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"cloud_account":{"id":"4f7daff2681151a840000001","name":"Cloud Account 1","cloud_id":"4f7f4ae2be8a7c052a000001","org_id":"4f32af1ebe8a7c6ef0000001", "cloud_services":[], "cloud_mappings":[], "prices": []}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## GET /stackstudio/v1/cloud_accounts/:id.json
Retrieves a representation of a cloud account, including associated details, such as cloud services and mappings.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /stackstudio/v1/cloud_accounts/4f62355abe8a7c148d000004.json HTTP/1.1
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

    {"cloud_account":{"id":"4f7daff2681151a840000001","name":"Cloud Account 1","cloud_id":"4f7f4ae2be8a7c052a000001","org_id":"4f32af1ebe8a7c6ef0000001", "cloud_services":[], "cloud_mappings":[], "prices": []}}

### Error Response:
None


## PUT /stackstudio/v1/cloud_accounts/:id
Updates an existing cloud account with new details.

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

    {"cloud_account":{"name":"Cloud Account 2"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"cloud_account":{"id":"4f7daff2681151a840000001","name":"Cloud   Account 2","cloud_id":"4f7f4ae2be8a7c052a000001","org_id":"4f32af1ebe8a7c6ef0000001", "cloud_services":[], "cloud_mappings":[], "prices": []}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}


## POST /stackstudio/v1/cloud_accounts/:id/services

Registers a new cloud service for a cloud account.

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

The updated cloud account payload

## DELETE /stackstudio/v1/cloud_accounts/:id/services/:service_id

Removes a cloud service from a cloud account.

### Arguments

* id - the cloud account's id
* service\_id - the service id owned by the cloud account

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/cloud_accounts/4f7daff2681151a840000001/services/4f7dcc04681151b0a5000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated cloud account payload

## POST /stackstudio/v1/cloud_accounts/:id/mappings

Registers a new cloud mapping for a cloud account.

### Arguments

* id - the cloud's id

### Response Status Codes:

* 200 - Mapping added

### Example Request:

    POST /stackstudio/v1/cloud_accounts/4f7daff2681151a840000001/mappings HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_mapping":{"name":"My Mapping","mapping_type":"My Mapping Type","properties":{},"mapping_entries":[]}}

### Response:

The updated cloud account payload

## DELETE /stackstudio/v1/cloud_accounts/:id/mappings/:mapping_id

Removes a cloud mapping from a cloud account.

### Arguments

* id - the cloud account's id
* mapping\_id - the mapping id owned by the cloud account

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/cloud_accounts/4f7daff2681151a840000001/mappings HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated cloud account payload
    