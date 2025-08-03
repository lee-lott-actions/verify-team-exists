#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f response.json "$GITHUB_OUTPUT" mock_response.json
}

@test "verify_team_exists succeeds with HTTP 200" {
  echo '' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run verify_team_exists "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'team-exists' "$GITHUB_OUTPUT")" == "team-exists=true" ]
}

@test "verify_team_exists fails with HTTP 404 (team not found)" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run verify_team_exists "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'team-exists' "$GITHUB_OUTPUT")" == "team-exists=false" ]
}

@test "verify_team_exists fails with empty team_name" {
  run verify_team_exists "" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'team-exists' "$GITHUB_OUTPUT")" == "team-exists=false" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: team_name, token, and owner must be provided." ]
}

@test "verify_team_exists fails with empty token" {
  run verify_team_exists "test-team" "" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'team-exists' "$GITHUB_OUTPUT")" == "team-exists=false" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: team_name, token, and owner must be provided." ]
}

@test "verify_team_exists fails with empty owner" {
  run verify_team_exists "test-team" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'team-exists' "$GITHUB_OUTPUT")" == "team-exists=false" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: team_name, token, and owner must be provided." ]
}
