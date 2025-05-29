<#
.SYNOPSIS
    Script to call Azure API Management with JWT token authentication.

.DESCRIPTION
    This PowerShell script demonstrates how to obtain a JWT token from Azure AD (Entra ID)
    and use it to authenticate API calls to Azure API Management.

.NOTES
    File Name      : callApiManagementWithJwtToken.ps1
    Author         : Azure Federal Development Team
    Prerequisite   : PowerShell 5.1 or later
    Version        : 1.0
    Date Created   : 2025-05-29

.EXAMPLE
    .\callApiManagementWithJwtToken.ps1

.LINK
    https://github.com/Azure-Samples/AzureFedDevBlog

.LICENSE
    MIT License

    Copyright (c) 2025 Microsoft Corporation

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

# Define variables
$tenantId = "your-tenant-id"  # Replace with your EntraID tenant ID
# You can find this in the Azure portal under EntraID > Properties
$clientId = "your-client-id"  # Replace with your EntraID application client ID
# You can find this in the Azure portal under EntraID > App registrations
$clientSecret = "your-client-secret"  # Replace with your EntraID application client secret
# You can find this in the Azure portal under EntraID > App registrations > Your app > Certificates & secrets
$scope = "$clientId/.default"  # Or another resource
$subscriptionKey = "your-subscription-key"  # Replace with your API Management subscription key (if required)

# Token endpoint
$tokenUrl = "https://login.microsoftonline.us/$tenantId/oauth2/v2.0/token"

# Prepare body
$body = @{
    client_id = $clientId
    scope = $scope
    client_secret = $clientSecret
    grant_type = "client_credentials"
}

# Request the token
$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ContentType "application/x-www-form-urlencoded"

# Output the access token
$token = $response.access_token

if (-not $token) {
    Write-Error "Failed to obtain access token."
    exit 1
}

# Prepare headers for API call
$headers = @{
    Authorization = "Bearer $token"
    "Ocp-Apim-Subscription-Key" = $subscriptionKey
}
# Call the API Management endpoint
# Replace the URL with your API Management endpoint
$outputValue = Invoke-RestMethod -Uri "https://apim.yourdomain.com/apiName/operationName" -Headers $headers -Method Get

Write-Output $outputValue
