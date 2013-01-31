# StackStudio Projects API

Create and manage projects for StackStudio. Projects contain one or more versions that are frozen (e.g. no changes allowed), plus a "current" working version that may be modified. Version numbers for projects must take the form of major.minor.patch, where:

* An update to the patch number is considered aesthetic and does not impact functionality
* An update to the minor number indicates a functionality change but should be backward compatible to a past version with the same major and minor number
* An update to the major number indicates a considerable change and likely not backward compatible

In addition, projects have a baseline design and may have one or more environments that capture the changes from the baseline. These differences between the baseline design and one or more environments are captured as Variants. Variants are rules that override the baseline design, including property value changes, removed resources, or added resources. 

Projects contain Elements, which may be visual or non-visual in nature. Elements that need to be visualized have a corresponding Node that includes the x,y coordinate and the view (i.e. "sheet" or "tab" that the node is to be displayed on). 

Nodes may contain NodeLinks, which allow connecting lines to be drawing from a source to a target node. NodeLinks are associated to the source only, creating a one-way relationship. Only one NodeLink may be assigned to a source/target pair. To draw a second line from the same node pair, create an inverse link where the target is the source and source is the target. 

When a project is provisioned, the version and environment are captured in a ProvisionedVersion, along with any ProvisionedInstances. This allows for tracking specific instance IDs of resources related to a provisioned stack and visualizing them within StackStudio.

Projects may also contain other projects through the EmbeddedProjects model. Only the baseline design from an embedded project is used within the master project. Any changes to the baseline of an embedded project should be captured as a Variant on the embedded project (not the master project). 

## GET /stackstudio/v1/projects

Returns a paginated list of projects

### Arguments

* page - The page number of the query. Defaults to 1 if not provided
* per_page - The number of results per page
* owner_id - Filter on the account id of the owner
* project_type - Filter on the type of project

### Response Status Codes:

* 200 - Query successful

### Example Request:

    GET /stackstudio/v1/projects?page=1 HTTP/1.1
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

    {"query":{"total":1,"page":1,"offset":0,"per_page":20,"links":[]},"projects":[{"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 2","description":"My second project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}}}}]}

### Error Response:
None

## POST /stackstudio/v1/projects/

Creates a new project in the system

### Response Status Codes:

* 201 - Project was created. Response body will contain the JSON with the project details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    POST /stackstudio/v1/projects HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"project":{"name":"Project 1","description":"My first project","project_type":"standard","cloud_account_id":"4f7f4ae2be8a7c052a000001","owner_id":"4f32af1ebe8a7c6ef0000001"}}

### Response:

    HTTP/1.1 201 Created
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}}]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## POST /stackstudio/v1/projects/:id/open/:account_id

"Opens" a project for a given account ID and retrieves a representation of an project, including associated details. This will update the last_opened_at for an account's project membership, which is available via the Identity Account's #auth and #details APIs.

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /stackstudio/v1/projects/4f84708bbe8a7c3355000001.json HTTP/1.1
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

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}}]}}

### Error Response:
None

## POST /stackstudio/v1/projects/:id

Gets a project

### Response Status Codes:

* 200 - Success. Response is a JSON payload with the details
* 404 - Not found

### Example Request:

    GET /stackstudio/v1/projects/4f84708bbe8a7c3355000001.json HTTP/1.1
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

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}}]}}

### Error Response:
None


## PUT /stackstudio/v1/projects/:id
Updates an existing project with new details.

__NOTE:__ All details must be sent on the update, otherwise fields with missing values will be set to an empty value. NO INCREMENTAL UPDATES ARE CURRENTLY SUPPORTED.

### Response Status Codes:

* 200 - Operation succeeded. Response is a JSON payload with the details
* 400 - Bad request by the client. Response body will contain a JSON message with the error details, including any validation errors associated to each field

### Example Request:

    PUT /stackstudio/v1/projects/4f84708bbe8a7c3355000001 HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"project":{"name":"Project 2","description":"My second project","project_type":"standard","cloud_account_id":"4f7f4ae2be8a7c052a000001","owner_id":"4f32af1ebe8a7c6ef0000001"}}

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}}]}}

### Error Response:

    HTTP/1.1 400 Bad Request
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 97
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"error":{"message":"Name can't be blank","validation_errors":{"name":["can't be blank"]}}}

## DELETE /stackstudio/v1/projects/:id
Permanently deletes a project, including all associated templates and other details. See the archive action for a non-destructive deletion of a project. 

### Response Status Codes:

* 200 - Operation succeeded
* 404 - Project not found

### Example Request:

    DELETE /stackstudio/v1/projects/4f84708bbe8a7c3355000001 HTTP/1.1
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

## POST /stackstudio/v1/projects/:id/archive

Marks the project as archived. No changes are allowed after a project has been archived.

### Arguments

* id - the project's id

### Response Status Codes:

* 200 - Project archived

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/archived HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"archived","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}}]}}


## POST /stackstudio/v1/projects/:id/reactivate

Marks the project as active once again. Changes are allowed.

### Arguments

* id - the project's id

### Response Status Codes:

* 200 - Project activated

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/reactivate HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

### Response:

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}}]}}


## POST /stackstudio/v1/projects/:id/freeze_version

Freezes the current version of the project, assigning a new version number and associated change log description. The new version number must be greater than the last version number

### Response Status Codes:

* 201 - Version created
* 400 - Validation failed, likely because the version's number field is not greater than the last version number provided

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/freeze_version HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"version":{"number":"1.1.1","description":"Minor change to the xyz..."}

### Response:

    {"project":{"id":"4f84708bbe8a7c3355000001","status":"active","name":"Project 1","description":"My first project","project_type":"standard","owner":{"id":"4f32af1ebe8a7c6ef0000001","login":"tester"},"cloud_account":{"cloud_account":{"id":"4f7f4ae2be8a7c052a000001","cloud_id":"4f7b5b48be8a7c5521000001","cloud_name":"James Test Cloud","name":"James Cloud Acct 1","access_key":"my access","secret_key":"my secret","key_pairs":[{"key_pair":{"id":"4f7f4c14be8a7c052a000002","name":"Key Pair 1","fingerprint":"my fingerprint","material":"my material"}}]}},"versions":[{"version":{"number":"1.1.0","description":"Added xyz feature","environments":["environment":{"name":"development"}]}},{"version":{"number":"1.1.1","description":"Minor change to the xyz..."},"environments":["environment":{"name":"development"}]]}}


## POST /stackstudio/v1/projects/:project_id/versions/:version/promote

Promotes the project version

### Arguments

* project_id - the project's id
* version - the version to promote (e.g. '1.0.1')

### Response Status Codes:

* 201 - Project version promoted
* 400 - Validation failed, likely because the environment already exists

### Example Request:

    POST /stackstudio/v1/projects/4f84708bbe8a7c3355000001/versions/1.0.1/promote HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70
    Content-Type: application/x-www-form-urlencoded

    {"environment":{"name":"staging"}}

### Response:

The updated project payload

## GET /stackstudio/v1/projects/:project_id/versions/:version.json

Retrieves the details for a specific version of a project. 

### Arguments

* project_id - the project's id
* version - the version to retrieve (e.g. '1.0.1'), or 'current' for the latest working copy

### Response Status Codes:

* 404 - Project or version not found

### Example Request:

    GET /stackstudio/v1/projects/4f8dcc25be8a7c039e000002/versions/current.json HTTP/1.1
    Connection: close
    Host: api.stackplace.com
    Content-Length: 70

### Response:

    HTTP/1.1 200 OK
    X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 82
    Connection: close
    Server: thin 1.3.1 codename Triple Espresso

    {"project_version":{"id":"4f8dcc25be8a7c039e000004","version":"current","environments":["environment":{"name":"development"},"environment":{"name":"test"}],"elements":[],"nodes":[]}}


