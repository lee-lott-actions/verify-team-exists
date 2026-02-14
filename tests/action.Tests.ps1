Describe "Test-TeamExists" {
    BeforeAll {
        $script:TeamName  = "test-team"
        $script:Token     = "fake-token"
        $script:Owner     = "test-owner"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
    BeforeEach {
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        $env:MOCK_API = $script:MockApiUrl
    }
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Variable -Name MOCK_API -Scope Global -ErrorAction SilentlyContinue
    }

    It "verify_team_exists succeeds with HTTP 200" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 200; Content = '' }
        }
        Test-TeamExists -TeamName $TeamName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "team-exists=true"
    }

    It "verify_team_exists fails with HTTP 404 (team not found)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 404; Content = '{"message": "Not Found"}' }
        }
        Test-TeamExists -TeamName $TeamName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "team-exists=false"
    }

	It "verify_team_exists handles non-200/non-404 HTTP status in else block (e.g., 500)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 500; Content = '{"message": "Server Error"}' }
        }
        Test-TeamExists -TeamName $TeamName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "team-exists=false"
    }

    It "verify_team_exists fails with empty team_name" {
        Test-TeamExists -TeamName "" -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "team-exists=false"
        $output | Should -Contain "error-message=Missing required parameters: team_name, token, and owner must be provided."
    }

    It "verify_team_exists fails with empty token" {
        Test-TeamExists -TeamName $TeamName -Token "" -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "team-exists=false"
        $output | Should -Contain "error-message=Missing required parameters: team_name, token, and owner must be provided."
    }

    It "verify_team_exists fails with empty owner" {
        Test-TeamExists -TeamName $TeamName -Token $Token -Owner ""
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "team-exists=false"
        $output | Should -Contain "error-message=Missing required parameters: team_name, token, and owner must be provided."
    }
	
	It "writes result=failure and error-message on exception" {
		Mock Invoke-WebRequest { throw "API Error" }

		Test-TeamExists -TeamName $TeamName -Token $Token -Owner $Owner

		$output = Get-Content $env:GITHUB_OUTPUT
		$output | Should -Contain "result=failure"
		$output | Should -Contain "team-exists=false"
		$output | Where-Object { $_ -match "^error-message=Error: Failed to verify Team '$TeamName' exists in organization '$Owner'\. Exception:" } |
			Should -Not -BeNullOrEmpty
	}	
}
