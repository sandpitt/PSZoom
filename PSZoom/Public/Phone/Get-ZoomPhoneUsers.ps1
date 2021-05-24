<#

.SYNOPSIS
Retrieves the ID, phone_user_id, name, and email.

.DESCRIPTION
Retrieves the ID, phone_user_id, name, and email.


.PARAMETER PageSize


.PARAMETER NextPageToken


.PARAMETER site_id


.PARAMETER ApiKey
The API Key.

.PARAMETER ApiSecret
The API Secret.

.OUTPUTS
When using -Full switch, receives JSON Response that looks like:
   {
  "next_page_token": "",
  "page_size": 30,
  "total_records": 1,
  "users": [
    {
      "calling_plans": [
        {
          "name": "US/CA Unlimited Calling Plan",
          "type": 200
        }
      ],
      "id": "z8ghgfh8uQ",
      "phone_user_id": "EMhghghg5w",
      "email": "sghhgghf@ghghmail.com",
      "name": "Shri Shri",
      "extension_number": 10000,
      "status": "activate",
      "site": {
        "id": "CESEpjWwT-upVH7kt_ixWA",
        "name": "Main Site"
      }
    }
  ]
}


.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listphoneusers

.EXAMPLE
Get-ZoomPhoneUsers
#>

function Get-ZoomPhoneUsers {
    [CmdletBinding()]
    param (
         #The number of records returned within a single API call (Zoom default = 30)
        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 2
        )]
        [ValidateRange(30, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,
        
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/phone/users"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        
        $query.Add('page_size', $PageSize)
        
        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
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
            Write-Output $response.users
        }
        
    }
}
