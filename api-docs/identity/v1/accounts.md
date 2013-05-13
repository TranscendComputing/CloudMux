# Identity Accounts API

## POST /identity/v1/accounts/
Creates a new account in the system. An organization is also created if the account request does not have an org_id.

Note: login and email must both be unique in the system to ensure that the user can login using either of these fields.

### Response Status Codes:

* 201 - Account was created. Response body will contain the JSON with the account details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /identity/v1/accounts HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"account":{"login":"foo2","email":"foo@bar.com","password":"foobar","country_code":"United States"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f3194bbbe8a7c6d8e000001","login":"foo2","email":"foo@bar.com"}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Login is already taken","validation_errors":{"login":["is already taken"]}}}


## POST /identity/v1/accounts/auth
Requests authentication of an existing account given a login/email and password.

### Response Status Codes:

* 200 - Authentication succeeded. Response is a JSON payload with the account's details
* 400 - Bad request by the client. Response is a JSON payload with the error message. Likely missing the login and password parameters as part of the POST
* 401 - Not authorized. Response is a JSON payload with the error message

### Example Request:

    POST /identity/v1/accounts/auth HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 26
    Content-Type: application/x-www-form-urlencoded

    login=foo2&password=foobar"

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f3194bbbe8a7c6d8e000001","login":"foo2","email":"foo@bar.com","subscriptions":[{"subscription":{"org_id":"4f60e9edbe8a7c0c40000001","org_name":"Test 2","product":"my_product","billing_level":"platinum","role":"admin"}},{"subscription":{"org_id":"4f62355abe8a7c148d000004","org_name":"Test Org","product":"stack-studio","billing_level":"platinum","role":"admin"}}],"project_memberships":[]}}


### Error Response:

    HTTP/1.1 401 Unauthorized
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 49
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Invalid login or password"}}


## GET /identity/v1/accounts/:id.json
Retrieves a representation of an account. Useful to ensure that the most current information is available, such as an email address, in case it was changed from a different system since the last authentication.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the account's details
* 404 - Not found

### Example Request:

    GET /identity/v1/accounts/4f3194bbbe8a7c6d8e000001.json HTTP/1.1
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

    {"account":{"id":"4f3194bbbe8a7c6d8e000001","login":"foo2","email":"foo@bar.com","subscriptions":[{"subscription":{"org_id":"4f60e9edbe8a7c0c40000001","org_name":"Test 2","product":"my_product","billing_level":"platinum","role":"admin"}},{"subscription":{"org_id":"4f62355abe8a7c148d000004","org_name":"Test Org","product":"stack-studio","billing_level":"platinum","role":"admin"}}],"project_memberships":[{"membership":{"project_id":"4f84708bbe8a7c3355000001","project_name":"Project 2","role":"member","last_opened_at":"2012-04-25T16:43:32-05:00"}}]}}

### Error Response:
None

## PUT /identity/v1/accounts/:id
Updates an existing account with new details, including the password. If no password is provided, the account's password is not changed.

__NOTE:__ All account details must be sent on the update, otherwise fields with missing values will be set to an empty value. NO INCREMENTAL UPDATES ARE CURRENTLY SUPPORTED.

### Response Status Codes:

* 200 - Authentication succeeded. Response is a JSON payload with the account's details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /identity/v1/accounts/4f3194bbbe8a7c6d8e000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"account":{"login":"foo2","email":"foo@bar.com","password":"foobar"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f3194bbbe8a7c6d8e000001","login":"foo2","email":"foo@bar.com"}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Login is already taken","validation_errors":{"login":["is already taken"]}}}

## GET /identity/v1/accounts/countries.json

Retrieves a list of all registered countries available. This API currently does not perform pagination, opting to return all results in one payload.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the account's details

### Example Request:

    GET /identity/v1/accounts/countries.json HTTP/1.1
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

    {"query":{"total":212,"page":1,"offset":0,"per_page":500,"links":[]},"countries":[{"country":{"code":"United States","name":"United States"}},{"country":{"code":"Canada","name":"Canada"}},{"country":{"code":"Albania","name":"Albania"}}]}

### Error Response:
None


## POST /identity/v1/accounts/:id/:cloud\_account\_id/cloud\_credentials
Register a cloud credentials to an existing user account

### Response Status Codes:

* 201 - Created successfully. Response body will contain the JSON with the account details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/4f7b5b48be8a7c5521000001/cloud_credentials HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_credential":{"name":"Cloud Cred 1","description","Test cloud credential","access_key":"my access","secret_key":"my secret"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[]}}]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## PUT /identity/v1/accounts/:id/cloud\_credentials/:cloud\_credential\_id
Update an existing cloud credential for an existing user account

### Response Status Codes:

* 200 - Updated successfully
* 404 - Account or Cloud Credential not found

### Example Request:

    PUT /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/cloud_credentials/4f7f4ae2be8a7c052a000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"cloud_credential":{"name":"Cloud Cred 1", "description":"Test cloud credential","access_key":"my access","secret_key":"my secret"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[]}}]}}
    

### Error Response:
None


## DELETE /identity/v1/accounts/:id/cloud\_credentials/:cloud\_credential\_id
Remove an existing cloud credential from an existing user account

### Response Status Codes:

* 200 - Deleted successfully
* 404 - Account or Cloud Credential not found

### Example Request:

    DELETE /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/cloud_credentials/4f7f4ae2be8a7c052a000001 HTTP/1.1
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

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[]}}

### Error Response:
None


## POST /identity/v1/accounts/:id/:cloud\_credential\_id/key\_pairs
Register a new key pair for a cloud credential

### Response Status Codes:

* 201 - Created successfully. Response body will contain the JSON with the account details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/4f7f4ae2be8a7c052a000001/key_pairs HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"key_pair":{"name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}}]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## DELETE /identity/v1/accounts/:id/:cloud\_credential\_id/:key\_pair\_id
Remove an existing key pair from a user account's cloud credential

### Response Status Codes:

* 200 - Deleted successfully
* 404 - Account, Cloud Credential, or Key Pair not found

### Example Request:

    DELETE /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/cloud_credentials/4f7f4ae2be8a7c052a000001/key_pairs/4f7f4c14be8a7c052a000002 HTTP/1.1
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

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[]}}]}}

### Error Response:
None

## POST /identity/v1/accounts/:id/:cloud\_credential\_id/audit\_logs
Log a cloud api request for a cloud credential

### Response Status Codes:

* 201 - Created successfully. Response body will contain the JSON with the account details

### Example Request:

    POST /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/4f7f4ae2be8a7c052a000001/audit_logs HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"audit_log":{"service_type":"EC2","action":"launch_instances","parameters":{"instance_type":"m1.small","image_id":"ami-00000000", "key_name":"mykey"},"response_status_code":"200","errors":{},"date":"2012-06-14 14:00:00 -500"}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}],"audit_logs":[{"audit_log":{"id":"4f6r4c14bf6a7c134a000002","service_type":"EC2","action":"launch_instances","parameters":{"instance_type":"m1.small","image_id":"ami-00000000", "key_name":"mykey"},"response_status_code":"200","errors":{},"date":"2012-06-14 14:00:00 -500"}}]}}]}}

### Error Response:
None

## POST /identity/v1/accounts/:id/permissions
Register a permission for an account

### Response Status Codes:

* 201 - Created successfully. Response body will contain the JSON with the account details

### Example Request:

    POST /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/permissions HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"permission":{"name":"permission_name","environment":"environment_name"}}

### Response:

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}],"audit_logs":[{"audit_log":{"id":"4f6r4c14bf6a7c134a000002","service_type":"EC2","action":"launch_instances","parameters":{"instance_type":"m1.small","image_id":"ami-00000000", "key_name":"mykey"},"response_status_code":"200","errors":{},"date":"2012-06-14 14:00:00 -500"}}]}}]}}

## DELETE /identity/v1/accounts/:id/permissions/:permission\_id
Register a permission for an account

### Response Status Codes:

* 200 - Deleted successfully. Response body will contain the JSON with the account details

### Example Request:

    DELETE /identity/v1/accounts/4f32af1ebe8a7c6ef0000001/permissions/4d32af2ebe8a7c5ef0000008 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

    {"account":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester","email":"info@example.com","subscriptions":[],"cloud_credentials":[{"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"Test Cloud","name":"Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}],"audit_logs":[{"audit_log":{"id":"4f6r4c14bf6a7c134a000002","service_type":"EC2","action":"launch_instances","parameters":{"instance_type":"m1.small","image_id":"ami-00000000", "key_name":"mykey"},"response_status_code":"200","errors":{},"date":"2012-06-14 14:00:00 -500"}}]}}]}}

	
## GET /identity/v1/accounts/cloud_credentials/:id.json
Retrieves a cloud credential that exists within a user's account. This is strictly for provisioning purposes, as cloud credentials do not exist outside of an account.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /identity/v1/accounts/cloud_credentials/4f7f4ae2be8a7c052a000001.json HTTP/1.1
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

     {"cloud_credential":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Cred 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}}

### Error Response:
None

