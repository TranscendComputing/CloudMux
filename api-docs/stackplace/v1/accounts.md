# Accounts API

## GET /stackplace/v1/accounts/:id.json
Retrieves the public information about an account, either by the account's ID or login

### Response Status Codes:
 
* 200 - Success. Response is a JSON payload with the account's details
* 404 - Not found

### Example Request:

    GET /stackplace/v1/accounts/foo2.json HTTP/1.1
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
     
    {"account":{"id":"4f3194bbbe8a7c6d8e000001","login":"foo2"}}

### Error Response:
None
