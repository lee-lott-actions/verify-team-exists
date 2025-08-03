#!/bin/bash

verify_team_exists() {
  local team_name="$1"
  local token="$2"
  local owner="$3"

  if [ -z "$team_name" ] || [ -z "$token" ] || [ -z "$owner" ]; then
    echo "Error: Missing required parameters"
    echo "result=failure" >> "$GITHUB_OUTPUT"
    echo "error-message=Missing required parameters: team_name, token, and owner must be provided." >> "$GITHUB_OUTPUT"        
    echo "team-exists=false" >> "$GITHUB_OUTPUT"
    return
  fi
  
  echo "Attempting to verify team '$team_name' exists in organization '$owner'"

  # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"

  # Make API request to check if the team exists
  RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    "$api_base_url/orgs/$owner/teams/$team_name")

  echo "API Response Code: $RESPONSE"  
  cat response.json

  if [ "$RESPONSE" -eq 200 ]; then
    echo "Team '$team_name' exists in organization '$owner'"
    echo "result=success" >> "$GITHUB_OUTPUT"
    echo "team-exists=true" >> "$GITHUB_OUTPUT"
  else
    echo "Team '$team_name' does not exist in organization '$owner'"
    echo "result=success" >> "$GITHUB_OUTPUT"
    echo "team-exists=false" >> "$GITHUB_OUTPUT"
  fi

  # Clean up temporary file
  rm -f response.json
}
