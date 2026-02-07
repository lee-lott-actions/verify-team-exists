function Test-TeamExists {
    param(
        [string]$TeamName,
        [string]$Token,
        [string]$Owner
    )

    # Validate required parameters
    if ([string]::IsNullOrEmpty($TeamName) -or
        [string]::IsNullOrEmpty($Token) -or
        [string]::IsNullOrEmpty($Owner)) {
        Write-Host "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: team_name, token, and owner must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "team-exists=false"
        return
    }

    Write-Host "Attempting to verify team '$TeamName' exists in organization '$Owner'"

    # Use MOCK_API if set, otherwise default to GitHub API
    $apiBaseUrl = $env:MOCK_API
    if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
    $uri = "$apiBaseUrl/orgs/$Owner/teams/$TeamName"

    $headers = @{
        Authorization  = "Bearer $Token"
        Accept         = "application/vnd.github+json"
        "Content-Type" = "application/json"
        "User-Agent"   = "pwsh-action"
    }

    try {
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get

        Write-Host "API Response Code: $($response.StatusCode)"
        Write-Host $response.Content

        if ($response.StatusCode -eq 200) {
            Write-Host "Team '$TeamName' exists in organization '$Owner'"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "team-exists=true"
        } else {
            Write-Host "Team '$TeamName' does not exist in organization '$Owner'"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "team-exists=false"
        }
    } catch {
		$errorMsg = "Error: Failed to verify Team '$TeamName' exists in organization '$Owner'. Exception: $($_.Exception.Message)"        
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "team-exists=false"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
    }
}