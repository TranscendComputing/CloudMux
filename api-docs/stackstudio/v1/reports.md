# StackStudio Report API

## GET /stackstudio/v1/report/users

Provides statistics about users within the system, for generating reports. 

### Response Status Codes:

* 200 - Report successful

### Example Request:

    GET /stackstudio/v1/users HTTP/1.1
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

    {"results":[{"login":"foo","email":"foo@bar.com","first_name":null,"last_name":null,"total_logins":0,"last_login_at":null,"total_projects_owned":0,"total_projects_member":0,"total_cloud_accounts":0}, {"login":"tester","email":"info@bluejazzconsulting.com","first_name":null,"last_name":null,"total_logins":1,"last_login_at":"2012-04-27T10:57:58-05:00","total_projects_owned":0,"total_projects_member":0,"total_cloud_accounts":1}]}