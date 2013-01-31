# StackPlace Categories API

The StackPlace Categories API allows for obtaining the complete list of categories current registered for categorizing stacks. The majority of the API is for internal use, as only StackPlace may add, update, or remote categories. However, the query API is offered to the public for offering navigation and stack creation user interfaces.

## GET /stackplace/v1/categories

Returns a complete list of categories registered at StackPlace. There is currently no pagination support, as the list is limited and fully managed by StackPlace.

### Response Status Codes:

* 200 - Query successful

### Example Request:

    GET /stackplace/v1/categories
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

    {
       "query":{"total":12,"page":1,"offset":0,"per_page":100, "links":[]},
       "categories":[
           {
             "category":{"id":"4f396f96be8a7c2f95000001","name":"Category 1","description":"Category 1"},
             "category":{"id":"4f396f96be8a7c2f95000002","name":"Category 2","description":"Category 2"}
           }
         ]
     }

### Error Response:
None
