<#

.SYNOPSIS
Retrieves the ID, number, display_name, source, status, and number type.

.DESCRIPTION
Retrieves the ID, number, display_name, source, status, and number type.


.PARAMETER Type


.PARAMETER ExtensionType


.PARAMETER PageSize


.PARAMETER NextPageToken


.PARAMETER NumberType


.PARAMETER PendingNumbers


.PARAMETER SiteID


.PARAMETER ApiKey
The API Key.

.PARAMETER ApiSecret
The API Secret.

.OUTPUTS
When using -Full switch, receives JSON Response that looks like:
    {
  "next_page_token": "",
  "page_size": 30,
  "total_records": 2,
  "phone_numbers": [
    {
      "id": "execvbfgbgr",
      "number": "0000111100",
      "display_name": "abc",
      "source": "internal",
      "status": "pending",
      "number_type": "tollfree",
      "capability": [
        "incoming",
        "outgoing"
      ],
      "location": "Milpitas,California,United States",
      "assignee": {
        "id": "cgfdgfghghim",
        "name": "Peter Jenner",
        "extension_number": 12,
        "type": "user"
      },
      "site": {
        "id": "sdfsdfgrg",
        "name": "SF office"
      }
    },
    {
      "id": "fdgfdgfdh",
      "number": "111111111",
      "source": "external",
      "status": "available",
      "number_type": "toll",
      "location": "San Jose,California,United States",
      "assignee": {
        "id": "dfgdfghdfhgh",
        "name": "Receptionist",
        "extension_number": 1,
        "type": "autoReceptionist"
      },
      "site": {
        "id": "jhdfsdghfdg",
        "name": "San Jose office"
      }
    }
  ]
}


.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listaccountphonenumbers

.EXAMPLE
Get-ZoomPhoneNumbers
#>

function Get-ZoomPhoneNumbers {
    [CmdletBinding()]
    param (
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken,

        # Query response by number assignment
        [Parameter(Mandatory = $False)]
        [ValidateSet("assigned", "unassigned", "all", "byoc")]
        [string]$Type,
        
        # The type of assignee to whom the number is assigned.
        [Alias('extension_type')]
        [Parameter(Mandatory = $False)]
        [ValidateSet("user", "callQueue", "autoReceptionist", "commonAreaPhone")]
        [string]$ExtensionType,

         #The number of records returned within a single API call (Zoom default = 30)
        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 2
        )]
        [ValidateRange(30, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        # The type of phone number
        [Alias('number_type')]
        [Parameter(Mandatory = $False)]
        [ValidateSet("toll", "tolfree")]
        [string]$NumberType,
        

        # Include or exclude pending numbers in the response
        [Alias('pending_numbers')]
        [Bool]$PendingNumbers = $true,

        # Unique identier of the site. Use this query paramater if you have multiple sites and would ilke to filter the response of this API call by a specific phone site
        [Alias('site_id')]
        [Parameter(Mandatory = $False)]
        [string]$SiteID,


        [switch]$Full = $False,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/phone/numbers"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        
        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($type) {
            $query.Add('type', $type)
        }

        if ($ExtensionType) {
            $query.Add('extension_type', $ExtensonType)
        }

        $query.Add('page_size', $PageSize)
        
        if ($NumberType) {
            $query.Add('number_type', $Numbertype)
        }

        if ($Pending_Numbers) {
            $query.Add('pending_numbers', $PendingNumbers)
        }

        if ($SiteID) {
            $query.Add('site_id', $SiteID)
        }

        $Request.Query = $query.ToString()
        

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret

        if ($Full) {
            Write-Output $response
        }
        else {
            Write-Output $response.phone_numbers
        }
        
    }
}
