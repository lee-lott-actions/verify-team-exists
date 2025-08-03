# Verify Team Exists Action

This GitHub Action validates if a specified GitHub team exists in an organization using the GitHub API. It returns whether the team exists (`true` or `false`) and an error message if the validation fails.

## Features
- Validates a GitHub team’s existence by making a GET request to the GitHub API.
- Expects a pre-slugified team name for API compatibility.
- Outputs whether the team exists (`team-exists`) and an error message if applicable.
- Requires a GitHub token with organization read permissions for authentication.
- Includes debug logging to ensure step output visibility in the GitHub Actions UI.

## Inputs
| Name        | Description                                              | Required | Default |
|-------------|----------------------------------------------------------|----------|---------|
| `team-name` | The slugified name of the team to validate (e.g., "code-approvers"). | Yes      | N/A     |
| `token`     | GitHub token with organization read permissions.         | Yes      | N/A     |
| `owner`     | The owner of the organization (user or organization).    | Yes      | N/A     |

## Outputs
| Name           | Description                                              |
|----------------|----------------------------------------------------------|
| `result`       | Result of the action ("success" or "failure")         |
| `team-exists`  | Whether the team exists in the organization (`true` or `false`). |
| `error-message`| Error message if the team existence check fails.         |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/verify-team-exists.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Verify Team Exists
   on:
     workflow_dispatch:
       inputs:
         team-name:
           description: 'Slugified name of the team to verify (e.g., "code-approvers")'
           required: true
   jobs:
     verify-team:
       runs-on: ubuntu-latest
       steps:
         - name: Verify Team Exists
           id: verify
           uses: lee-lott-actions/verify-team-exists@v1.0.0
           with:
             team-name: ${{ github.event.inputs.team-name }}
             token: ${{ secrets.GITHUB_TOKEN }}
             owner: ${{ github.repository_owner }}
         - name: Print Result
           run: |
             if [[ "${{ steps.verify.outputs.team-exists }}" == "true" ]]; then
               echo "Team ${{ github.event.inputs.team-name }} exists in organization ${{ github.repository_owner }}."
             else
               echo "Error: ${{ steps.verify.outputs.error-message }}"
               exit 1
             fi
