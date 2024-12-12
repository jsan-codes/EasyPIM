﻿<#
      .Synopsis
       invoke ARM REST API
      .Description
       wrapper function to get an access token and set authentication header for each ARM API call
      .Parameter RestURI
       the URI
      .Parameter Method
       http method to use
      .Parameter Body
       an optional body
      .Example
        PS> invoke-ARM -restURI $restURI -method "GET"

        will send an GET query to $restURI and return the response
      .Link
     
      .Notes
        Author: Loïc MICHEL
        Homepage: https://github.com/kayasax/EasyPIM
#>
function Invoke-ARM {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $restURI,

        [Parameter(Position = 1)]
        [System.String]
        $method,

        [Parameter(Position = 2)]
        [System.String]
        $body=""
    )

    try{
        <#$scope = "subscriptions/$script:subscriptionID"
        $ARMhost = "https://management.azure.com"
        $ARMendpoint = "$ARMhost/$scope/providers/Microsoft.Authorization"#>

        write-verbose "`n>> request body: $body"
        write-verbose "requested URI : $restURI ; method : $method"

        #TODO need better way to handle mangement group scope!!
        if($restURI -notmatch "managementgroups"){
            $script:subscriptionID=[regex]::Matches($restURI,".*\/subscriptions\/(.*)\/providers.*$").groups[1].Value


            if ( $null -eq (get-azcontext) -or ( (get-azcontext).Tenant.Id -ne $script:tenantID ) ) {
                Write-Verbose ">> Connecting to Azure with tenantID $script:tenantID"
                Connect-AzAccount -Tenantid $script:tenantID -Subscription $script:subscriptionID
            }
        }
        
    
        #replaced with invoke-azrestmethod
        <#
        # Get access Token
        Write-Verbose ">> Getting access token"
        # now this will return a securestring https://learn.microsoft.com/en-us/powershell/azure/upcoming-breaking-changes?view=azps-12.2.0#get-azaccesstoken
        $token = Get-AzAccessToken -AsSecureString
                
        # setting the authentication headers for MSGraph calls
        $authHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = 'Bearer ' + $($token.Token | ConvertFrom-SecureString -AsPlainText)
        }

        if($body -ne ""){
            $response = Invoke-RestMethod -Uri $restUri -Method $method -Headers $authHeader -Body $body -verbose:$false
        }
        else{
            $response = Invoke-RestMethod -Uri $restUri -Method $method -Headers $authHeader -verbose:$false
        }
            #>
        if ($body -ne ""){
            $response=Invoke-AZRestMethod -Method $method -Uri $restURI -payload $body
        }
        else {
            $response=Invoke-AZRestMethod -Method $method -Uri $restURI
        }
        
        return $response.content | convertfrom-json

    }
    catch{
        MyCatch $_
    }


}