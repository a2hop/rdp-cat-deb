# GitHub Actions Setup for rdp-cat-deb

## Required Repository Secret

You need to add one repository secret for the GitHub Actions workflow to function:

### DEB_BUILDER_PAT

**Name:** `DEB_BUILDER_PAT`  
**Type:** Personal Access Token (Classic or Fine-grained)  
**Required Permissions:**
- For Classic PAT: `repo` scope (to read releases from a2hop/rdp-cat)
- For Fine-grained PAT: `Contents: Read` permission on a2hop/rdp-cat repository

**How to add:**
1. Go to the repository settings: https://github.com/a2hop/rdp-cat-deb/settings/secrets/actions
2. Click "New repository secret"
3. Name: `DEB_BUILDER_PAT`
4. Value: Paste your GitHub Personal Access Token
5. Click "Add secret"

**Why it's needed:**
- The workflow downloads the rdp-cat binary from the a2hop/rdp-cat repository
- If that repository is private, authentication is required
- Even if public, using a token increases rate limits and ensures reliability

## Workflow Trigger

The workflow automatically runs when:
- Changes are pushed to `main` branch
- Changes affect:
  - `deb_version` file
  - `pkg/**` files
  - `.github/workflows/build_and_release.yaml`
- Manual trigger via workflow_dispatch

## Version Management

Edit the `deb_version` file to control versions:

```bash
DEB=1.0.0  # Debian package version (used for release tags)
BIN=1.0.0  # rdp-cat binary version to download from upstream
```

## What the Workflow Does

1. **Check Release**: Verifies if the release already exists
2. **Build**: For each architecture (amd64, arm64, armv7):
   - Downloads the rdp-cat binary from GitHub releases
   - Creates the Debian package structure
   - Builds the .deb package
   - Uploads as artifact
3. **Release**: 
   - Downloads all artifacts
   - Creates a GitHub release with tag `vX.Y.Z` (using DEB version)
   - Uploads all .deb packages and SHA256 checksums

## Testing

After pushing changes:
1. Check the Actions tab: https://github.com/a2hop/rdp-cat-deb/actions
2. Monitor the workflow run
3. If successful, check Releases: https://github.com/a2hop/rdp-cat-deb/releases

## Troubleshooting

If the workflow fails:

### "404 Not Found" when downloading binary
- Verify the release exists: https://github.com/a2hop/rdp-cat/releases/tag/1.0.0
- Check that the binary file is named exactly `rdp-cat`
- Ensure DEB_BUILDER_PAT has access to the repository

### "Release already exists"
- The workflow skips if a release with the same version exists
- Update the `DEB` version in `deb_version` file
- Or manually delete the old release and re-run

### "Downloaded file is HTML"
- Usually means the binary doesn't exist at that URL
- Verify the BIN version matches an actual release
- Check the binary filename in the release
