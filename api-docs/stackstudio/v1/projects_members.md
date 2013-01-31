## POST /stackstudio/v1/projects/:id/members

Adds a new member to the project

### Arguments

* id - the project's id

### Response Status Codes:

* 201 - Membership created

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/members HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"member":{"account_id":"4f35052cbe8a7c382a000002","role":"member"}}

### Response:

The updated project payload

## DELETE /stackstudio/v1/projects/:id/members/:member_id

Removes a membership from a project.

### Arguments

* id - the project's id
* member\_id - the membership id within the project (not the account id)

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001/members/4f7dcc04681151b0a5000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload

## POST /stackstudio/v1/projects/:id/members/:member_id/permissions

Adds a new permission to a project member.

### Arguments

* id - the project's id
* member\_id - the membership id within the project (not the account id)

### Response Status Codes:

* 201 - Permission created

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/members/4f7dcc04681151b0a5000001/permissions HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"permission":{"name":"view_source","environment":"development"}}

### Response:

The updated project payload

## POST /stackstudio/v1/projects/:id/members/:member_id/permissions/import

Adds multiple new permissions to a project member.

### Arguments

* id - the project's id
* member\_id - the membership id within the project (not the account id)

### Response Status Codes:

* 201 - Permissions created
* 200 - Not all permissions created

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/members/4f7dcc04681151b0a5000001/permissions/import HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"permissions":[{"permission":{"name":"first_permission","environment":"dev"}}, {"permission":{"name":"second_permission","environment":"dev"}}]}

### Response:

The updated project payload

## DELETE /stackstudio/v1/projects/:id/members/:member\_id/permissions/:permission\_id

Removes a permission from a project member.

### Arguments

* id - the project's id
* member\_id - the membership id within the project (not the account id)
* permission\_id - the permission id

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001/members/4f7dcc04681151b0a5000001/permissions/4d7dcc04681151b0a6000008 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload

## DELETE /stackstudio/v1/projects/:id/members/:member\_id/env_permissions/:environment

Removes all permissions for an environment from a project member.

### Arguments

* id - the project's id
* member\_id - the membership id within the project (not the account id)
* environment - the name of the environment

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001/members/4f7dcc04681151b0a5000001/env_permissions/dev HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload

###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################
###########################################################################################################################################

## POST /stackstudio/v1/projects/:id/groups/:group_id

Adds a group to the project

### Arguments

* id - the project's id
* group\_id - the group's id

### Response Status Codes:

* 201 - Membership created

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/groups/4f8dbc04681151b0a5000012 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload

## DELETE /stackstudio/v1/projects/:id/groups/:group_id

Removes a group from a project.

### Arguments

* id - the project's id
* group\_id - the group id

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001/groups/4f8dbc04681151b0a5000012 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload

## POST /stackstudio/v1/projects/:id/groups/:group_id/permissions

Adds a new permission to a project group.

### Arguments

* id - the project's id
* group\_id - the group id

### Response Status Codes:

* 201 - Permission created

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/groups/4f8dbc04681151b0a5000012/permissions HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"permission":{"name":"view_source","environment":"development"}}

### Response:

The updated project payload

## POST /stackstudio/v1/projects/:id/groups/:group_id/permissions/import

Adds multiple new permissions to a project group.

### Arguments

* id - the project's id
* group\_id - the group id

### Response Status Codes:

* 201 - Permissions created
* 200 - Not all permissions created

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/groups/4f8dbc04681151b0a5000012/permissions/import HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"permissions":[{"permission":{"name":"first_permission","environment":"dev"}}, {"permission":{"name":"second_permission","environment":"dev"}}]}

### Response:

The updated project payload

## DELETE /stackstudio/v1/projects/:id/groups/:group\_id/permissions/:permission\_id

Removes a permission from a project group.

### Arguments

* id - the project's id
* group\_id - the group id
* permission\_id - the permission id

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001/groups/4f8dbc04681151b0a5000012/permissions/4d7dcc04681151b0a6000008 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload

## DELETE /stackstudio/v1/projects/:id/groups/:group\_id/env_permissions/:environment

Removes all permissions for an environment from a project group.

### Arguments

* id - the project's id
* group\_id - the group id
* environment - the name of the environment

### Response Status Codes:

* 200 - Deleted

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001/groups/4f8dbc04681151b0a5000012/env_permissions/dev HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

The updated project payload
