# Identity Organizations API

## POST /identity/v1/orgs/

Creates a new org in the system.

### Response Status Codes:

* 201 - Org was created. Response body will contain the JSON with the org details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /identity/v1/orgs HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"org":{"name":"Test Org"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"org":{"id":"4f62355abe8a7c148d000004","name":"Test Org","subscriptions":[]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## GET /identity/v1/orgs/:id.json
Retrieves a representation of an org, including accounts associated and their roles.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /identity/v1/orgs/4f62355abe8a7c148d000004.json HTTP/1.1
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

    "org":{"id":"4f62355abe8a7c148d000004","name":"Test Org","subscriptions":[{"subscription":{"product":"stack-studio","billing_level":"platinum","subscribers":[{"account":{"id":"4f4ff648be8a7c2be0000001","login":"stackplace"},"role":"admin"}]}}]}}

### Error Response:
None

## PUT /identity/v1/orgs/:id
Updates an existing org with new details.

__NOTE:__ All details must be sent on the update, otherwise fields with missing values will be set to an empty value. NO INCREMENTAL UPDATES ARE CURRENTLY SUPPORTED.

### Response Status Codes:

* 200 - Authentication succeeded. Response is a JSON payload with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /identity/v1/orgs/4f62355abe8a7c148d000004 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"org":{"name":"Test Org 2"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"org":{"id":"4f62355abe8a7c148d000004","name":"Test Org 2","subscriptions":[]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## PUT /identity/v1/orgs/:id/:product/subscription

Creates and/or updates an org's subscription to a specific product.

### Arguments

* id - the org's id
* product - a short name for the product - internal use for identifying the subscription details of a specific product for the org. Suggest using something URL-friendly, such as stack-studio

### Response Status Codes:

* 200 - Subscription created/updated
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /identity/v1/orgs/4f62355abe8a7c148d000004/stack-studio/subscription HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"subscription":{"billing_level":"platinum"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"org":{"id":"4f62355abe8a7c148d000004","name":"Test Org","subscriptions":[{"subscription":{"product":"stack-studio","billing_level":"platinum","subscribers":[]}}]}}

## POST /identity/v1/orgs/:id/:product/subscribers

Adds a new account as a subscriber to an organization's product subscription with a specific role associated to the product/subscription. This association counts as a "license seat" for the specific product.

Note: If an account is added more than once, the original subscription is retained and the role is updated (in the case of a role promotion or demotion).

### Arguments

* id - the org's id
* product - a short name for the product

### Response Status Codes:

* 200 - Subscriber added
* 400 - Bad request by the client. Likely the subscription entry for the product product wasn't found

### Example Request:

    POST /identity/v1/orgs/4f62355abe8a7c148d000004/stack-studio/subscribers HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"subscriber":{"account_id":"4f4ff648be8a7c2be0000001","role":"admin"}}

### Response:

<empty>

## DELETE /identity/v1/orgs/:id/:product/subscribers/:subscriber\_account\_id

Removes an existing account as a subscriber to an organization's product subscription. This association counts as releasing a "license seat" for the specific product.

### Arguments

* id - the org's id
* product - a short name for the product
* subscriber\_account\_id - the account id for the user account that should be removed.

### Response Status Codes:

* 200 - Subscriber added
* 400 - Bad request by the client. Likely the subscription entry for the product product wasn't found
* 404 - Account not found

### Example Request:

    DELETE /identity/v1/orgs/4f62355abe8a7c148d000004/stack-studio/subscribers/4f4ff648be8a7c2be0000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

<empty>

## POST /stackplace/v1/orgs/:id/mappings

Registers a new cloud mapping for a cloud.

### Arguments

* id - the cloud's id

### Response Status Codes:

* 200 - Mapping added

### Example Request:

    POST /stackplace/v1/orgs/4f7daff2681151a840000001/mappings HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_mapping":{"name":"My Mapping","mapping_type":"My Mapping Type","properties":{},"mapping_entries":[]}}

### Response:

The updated org payload

## DELETE /stackplace/v1/orgs/:id/mappings/:mapping_id

Removes a cloud mapping from a cloud.

### Arguments

* id - the cloud's id
* mapping\_id - the mapping id owned by the cloud

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackplace/v1/orgs/4f7daff2681151a840000001/mappings/4f7dcc04681151b0a5000001 HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated org payload

## POST /stackplace/v1/orgs/:id/groups

Registers a new group to the org.

### Arguments

* id - the org id

### Response Status Codes:

* 200 - Group added

### Example Request:

    POST /stackplace/v1/orgs/4f7daff2681151a840000001/groups HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"group":{"name":"MyGroup","description":"new group"}}

### Response:

The updated org payload

## DELETE /stackplace/v1/orgs/:id/groups/:group_id

Removes a group from an org.

### Arguments

* id - the org's id
* group\_id - the group id owned by the org

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackplace/v1/orgs/4f7daff2681151a840000001/groups/4f8dbc04681151b0a5000012 HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated org payload

## POST /stackplace/v1/orgs/:id/groups/:group_id/accounts/:account_id

Registers a new account to the group.

### Arguments

* id - the org id
* group\_id - the group id owned by the org
* account\_id - the account id owned by the org

### Response Status Codes:

* 200 - Group added

### Example Request:

    POST /stackplace/v1/orgs/4f7daff2681151a840000001/groups/4f8dbc04681151b0a5000012/accounts/5c7dbc04681151b0a5000002 HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated org payload

## DELETE /stackplace/v1/orgs/:id/groups/:group_id/accounts/:account_id

Removes an account from a group.

### Arguments

* id - the org's id
* group\_id - the group id owned by the org
* account\_id - the account id owned by the org

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackplace/v1/orgs/4f7daff2681151a840000001/groups/4f8dbc04681151b0a5000012/accounts/5c7dbc04681151b0a5000002 HTTP/1.1
    Connection: close
    Host: stackplace-mapping.herokuapp.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated org payload


