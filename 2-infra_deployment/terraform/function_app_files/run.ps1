<#
    .SYNOPSIS
    GitHub Action Webhook Trigger

    .DESCRIPTION
    PowerShell script that triggers from an IoT Hub request that will trigger a GitHub Action via webhook.

#>

#Bindings are passed via param block.
param($IoTHubMessages, $TriggerMetadata)

#Check JSON request from IoT device. If this does 
#not match, this script will exit immediately.
Write-Output "Function start. Validating IoT device claim"
$claim = $IoTHubMessages.claim
if ($claim -ne $($env:iotclaim)) {
    Write-Output "Claim code incorrect or not present. Script exiting"
    exit
}
Else {
    Write-Output "Claim code from IoT device matches"
}

#Webhook trigger for GitHub Actions
Write-Output "Building GitHub webhook request"
$headers = @{    
    'Authorization'="Bearer $($env:githubpat)"
    'Accept'="application/vnd.github+json"
}

$body = @{
    event_type = "azure_function_trigger"
} | ConvertTo-Json

$request = Invoke-WebRequest `
    -Uri "https://api.github.com/repos/$($env:githubowner)/$($env:githubreponame)/dispatches" `
    -Headers $headers `
    -Body $body `
    -Method POST

If ( $request.StatusCode -like "20*") {
    Write-Output "GitHub Action request sent successfully"
}
Else {
    Write-Output "GitHub Action request may have failed"
}
