# Docker Deployment Guide

## Overview

This document describes the Docker deployment setup for the Superdesign MCP Server, including automated builds to GitHub Container Registry (GHCR).

## Files Created

### 1. Dockerfile
Multi-stage Docker build configuration:
- **Builder stage**: Compiles TypeScript to JavaScript
- **Production stage**: Minimal Alpine Linux (~50MB) with only runtime dependencies
- **Security**: Non-root user (`mcp:mcp`, UID/GID 1001)
- **Signal handling**: Uses `dumb-init` for proper process management

### 2. .dockerignore
Excludes unnecessary files from Docker build context:
- Development dependencies
- IDE configurations
- Git metadata
- Test files
- Documentation

### 3. docker-compose.yml
Local development and testing configuration:
- Defines the main MCP server service
- Optional gallery server service (profile-gated)
- Volume mounts for persistent design storage
- Resource limits and health checks

### 4. .github/workflows/docker-publish.yml
Automated CI/CD pipeline with GitHub Actions:
- **Triggers**: Push to main, PR, manual dispatch, version tags
- **Multi-architecture builds**: amd64 and arm64
- **Security scanning**: Trivy vulnerability scanner
- **Attestations**: Build provenance for supply chain security

## Image Tags

Published to: `ghcr.io/jonthebeef/superdesign-mcp-claude-code`

| Tag | Description |
|-----|-------------|
| `latest` | Latest build from main branch |
| `v1.0.0` | Semantic version (full) |
| `v1.0` | Semantic version (minor) |
| `v1` | Semantic version (major) |
| `main-<sha>` | Commit-specific build |

## Quick Start

### Pull and Run

```bash
# Pull the image
docker pull ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest

# Run the server
docker run -i \
  -v $(pwd)/superdesign:/workspace/superdesign \
  ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest
```

### Using Docker Compose

```bash
# Start server
docker-compose up -d

# View logs
docker-compose logs -f

# Stop server
docker-compose down
```

## Claude Code Integration

Add to `~/.claude-code/mcp-settings.json`:

```json
{
  "mcpServers": {
    "superdesign": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "${workspaceFolder}/superdesign:/workspace/superdesign",
        "ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest"
      ],
      "env": {}
    }
  }
}
```

## Building Locally

```bash
# Build the image
docker build -t superdesign-mcp-server .

# Run locally built image
docker run -i \
  -v $(pwd)/superdesign:/workspace/superdesign \
  superdesign-mcp-server
```

## Release Process

### Creating a New Release

1. **Update version** in `package.json`:
   ```bash
   npm version patch  # or minor, or major
   ```

2. **Create and push git tag**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **GitHub Actions automatically**:
   - Builds multi-arch Docker images
   - Pushes to GHCR with semantic version tags
   - Runs security scans
   - Creates build attestations

### Testing Before Release

```bash
# Build locally
docker-compose build

# Test locally
docker-compose up -d

# Verify MCP tools work
docker-compose logs -f
```

## Production Considerations

### Security
- ✅ Non-root user execution
- ✅ Minimal base image (Alpine)
- ✅ Multi-stage builds
- ✅ Automated security scanning (Trivy)
- ✅ Supply chain attestations

### Performance
- Resource limits configurable via Docker Compose
- Health checks every 30s
- Efficient layer caching in multi-stage build

### Monitoring
- JSON-based logging
- Log rotation (10MB, 3 files)
- Health check endpoint

### Persistence
- Design files stored in mounted volumes
- Data survives container restarts
- Easy backup via volume management

## Troubleshooting

### Image Won't Pull
```bash
# Authenticate with GitHub
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Verify image exists
docker pull ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest
```

### Permission Issues
```bash
# Fix volume permissions
docker run --rm \
  -v $(pwd)/superdesign:/workspace/superdesign \
  alpine:latest \
  chown -R 1001:1001 /workspace/superdesign
```

### Container Won't Start
```bash
# Check logs
docker logs <container-id>

# Verify volume mounts
docker inspect <container-id>

# Test with interactive shell
docker run -it --entrypoint /bin/sh \
  ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest
```

## GitHub Actions Setup

### Required GitHub Secrets

No secrets required! The workflow uses:
- `${{ secrets.GITHUB_TOKEN }}` - Automatically provided by GitHub
- Permissions configured in workflow file

### Enabling GitHub Container Registry

1. Repository Settings → Actions → General
2. Workflow permissions → Read and write permissions
3. Allow GitHub Actions to create and approve pull requests (optional)

### Monitoring Builds

- View workflows: `https://github.com/jonthebeef/superdesign-mcp-claude-code/actions`
- Check packages: `https://github.com/jonthebeef?tab=packages`
- Security alerts: Repository → Security → Code scanning

## Next Steps

1. **Push to GitHub**: Commit and push all Docker files
2. **Test workflow**: Create a test tag to verify CI/CD
3. **Enable package visibility**: Make GHCR package public (optional)
4. **Documentation**: Update main README with Docker instructions ✅
5. **First release**: Tag `v1.0.0` to trigger first automated build

## Additional Resources

- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Actions for Docker](https://docs.docker.com/build/ci/github-actions/)