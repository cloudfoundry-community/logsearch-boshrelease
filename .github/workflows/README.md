# GitHub Actions Release Workflow

This repository includes an automated release workflow that builds and publishes BOSH releases when tags are pushed.

## How it works

The workflow (`release.yml`) triggers when a tag matching `v*` is pushed to the repository. It will:

1. Extract the version from the git tag (e.g., `v212.0.0` becomes `212.0.0`)
2. Set up the BOSH CLI environment
3. Create a final BOSH release with the specified version
4. Generate a release tarball and SHA256 checksum
5. Commit the release files back to the repository
6. Create a GitHub release with release notes and artifacts

## Required Secrets

Configure these repository secrets in GitHub Settings → Secrets and variables → Actions:

- `AWS_ACCESS_KEY_ID` - AWS access key for the S3 blobstore
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for the S3 blobstore
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions

## Release Process

1. Update `ci/release_notes.md` with your release notes
2. Create and push a version tag:
   ```bash
   git tag v212.0.0
   git push origin v212.0.0
   ```
3. The workflow will automatically:
   - Build the BOSH release
   - Generate the tarball and checksum
   - Commit release files to the repository
   - Create a GitHub release with proper notes

## Release Artifacts

Each release includes:
- `logsearch-X.Y.Z.tgz` - The BOSH release tarball
- `logsearch-X.Y.Z.tgz.sha256` - SHA256 checksum file
- Release notes with YAML deployment stanza

## Release Notes Format

The workflow automatically appends a deployment section to release notes with the proper YAML stanza:

```yaml
releases:
- name:    logsearch
  version: X.Y.Z
  url:     https://github.com/cloudfoundry-community/logsearch-boshrelease/releases/download/vX.Y.Z/logsearch-X.Y.Z.tgz
  sha1:    sha256:abcd1234...
```