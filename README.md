# Superdesign MCP Server

An MCP (Model Context Protocol) server that brings [Superdesign](https://github.com/superdesigndev/superdesign) - an open source AI design agent by [@jasonzhou1993](https://twitter.com/jasonzhou1993) and [@jackjack_eth](https://twitter.com/jackjack_eth) - to Claude Code as native tools. This server operates as a "design orchestrator" that provides structured specifications for your IDE's LLM to execute, enabling Superdesign's sophisticated design capabilities without requiring Anthropic API keys.

## Key Benefits

- **No API Keys Required**: Works directly with Claude Code's built-in LLM connection
- **Local Execution**: Runs entirely on your machine as an MCP server
- **IDE Integration**: Seamlessly integrates with Claude Code (and potentially Cursor, Windsurf, or other MCP-compatible IDEs - untested)
- **Based on Open Source**: Built on top of [Superdesign.dev](https://www.superdesign.dev), an open source AI design system

## Installation

### Option 1: Docker (Recommended)

Pull and run from GitHub Container Registry:

```bash
# Pull the latest image
docker pull ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest

# Run with docker-compose (easiest)
docker-compose up -d

# Or run directly
docker run -i \
  -v $(pwd)/superdesign:/workspace/superdesign \
  ghcr.io/jonthebeef/superdesign-mcp-claude-code:latest
```

**Docker Configuration for Claude Code:**

Add to your `~/.claude-code/mcp-settings.json`:

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

### Option 2: Local Build from Source

1. Clone the repository:
```bash
git clone https://github.com/jonthebeef/superdesign-mcp-claude-code.git
cd superdesign-mcp-claude-code
```

2. Install dependencies:
```bash
npm install
```

3. Build the server:
```bash
npm run build
```

## Claude Code Integration

1. Add the MCP server to your Claude Code configuration:
```bash
# Create or edit your Claude Code MCP settings file
# On macOS:
mkdir -p ~/.claude-code
cp claude-mcp-config.json ~/.claude-code/mcp-settings.json

# Or add manually to your existing mcp-settings.json:
```

Example `~/.claude-code/mcp-settings.json`:
```json
{
  "mcpServers": {
    "superdesign": {
      "command": "node",
      "args": ["/path/to/superdesign/dist/index.js"],
      "env": {}
    }
  }
}
```

2. Restart Claude Code

3. The MCP server will provide these Superdesign orchestrator tools in Claude Code:
   - `superdesign_generate` - Returns specifications for Claude to generate designs
   - `superdesign_iterate` - Returns instructions for Claude to iterate on existing designs
   - `superdesign_extract_system` - Returns instructions for design system extraction
   - `superdesign_list` - Lists all created designs in the workspace

## Development

Run in development mode:
```bash
npm run dev
```

## Superdesign Tools Available

### superdesign_generate
Returns structured specifications for Claude Code to generate designs:
- **UI designs**: Complete responsive interfaces
- **Wireframes**: Minimal black and white layouts  
- **Components**: Individual UI components (HTML/React/Vue)
- **Logos**: SVG logo designs
- **Icons**: SVG icon designs

Parameters:
- `prompt`: Description of what to create
- `design_type`: Type of design (ui, wireframe, component, logo, icon)
- `variations`: Number of variations to generate (1-5, default 3)
- `framework`: Framework for components (html, react, vue)

**Output**: Detailed specifications including Superdesign system prompt, file naming patterns, and design guidelines for Claude Code to execute.

### superdesign_iterate
Returns iteration instructions for Claude Code to improve existing designs:
- Reads existing design files  
- Provides structured feedback application guidelines
- Maintains design consistency through Superdesign principles

Parameters:
- `design_file`: Path to existing design file
- `feedback`: Improvement instructions
- `variations`: Number of variations to create

**Output**: Iteration specifications including original design content, feedback to apply, and Superdesign guidelines for Claude Code to execute.

### superdesign_extract_system
Returns instructions for Claude Code to extract design systems from screenshots:
- Provides analysis framework for visual design patterns
- Guides extraction of color palettes, typography, spacing
- Specifies JSON structure for reusable design systems

**Output**: Extraction specifications and JSON schema for Claude Code to analyze images and create design system files.

### superdesign_list
List all Superdesign creations in workspace:
- Shows design iterations
- Shows extracted design systems
- Displays file organization

### superdesign_gallery
Generate an interactive HTML gallery to view all designs:
- **Browser-based gallery** - opens in your default browser
- **Visual previews** - see design thumbnails in a responsive grid
- **Interactive features** - click to view full-screen, copy paths
- **Mobile responsive** - works on desktop, tablet, and mobile
- **Auto-discovery** - finds all HTML/SVG files in design_iterations/

Parameters:
- `workspace_path`: Workspace directory (optional, defaults to current directory)

**Output**: Gallery HTML file with embedded previews and JavaScript interactions. The gallery opens automatically in your browser, providing a Superdesign-like canvas experience.

## How the Orchestrator Works

This MCP server operates as a **design orchestrator** rather than a direct generator:

1. **User Request**: "Generate a modern dashboard UI"
2. **MCP Server**: Returns detailed specifications with:
   - Complete Superdesign system prompt and guidelines
   - Exact file paths and naming conventions
   - Design type-specific instructions
   - Number of variations to create
3. **Claude Code**: Receives specifications and:
   - Generates the actual HTML/SVG/React code
   - Saves files to specified locations
   - Follows all Superdesign design principles

## Usage in Claude Code

Once configured, you can use Superdesign through Claude Code with natural language:

**Example Usage:**
- "Generate a modern dashboard UI design"
- "Create 3 variations of a login page wireframe"  
- "Design a React component for a product card"
- "Make a minimalist logo for a tech startup"
- "Iterate on the dashboard design with better spacing"
- "Show me the gallery of all my designs"

**Requirements:**
- Claude Code with MCP support
- No API keys needed (uses Claude Code's existing LLM connection)

**File Organization:**
Designs are automatically saved to `superdesign/` directory (visible folder):
- `design_iterations/` - Generated designs (HTML/SVG files)
- `design_system/` - Extracted design systems (JSON files)

**Benefits:**
- No API key configuration required
- Uses Claude Code's existing LLM capabilities
- Maintains all of Superdesign's sophisticated design methodology
- Proper file organization and naming conventions
- Full design iteration workflow support

## Known Issues & Troubleshooting

### File Permissions Error
If you encounter permission errors when running the MCP server:
```bash
# Add execute permissions to the built file
chmod +x dist/index.js
```

### MCP Tools Not Appearing
If Superdesign tools don't appear in Claude Code after installation:
1. Ensure you've completely quit Claude Code (not just closed the window)
2. Restart Claude Code from your terminal
3. Verify the server is registered: `claude mcp list`
4. Check the tools are available by asking Claude: "What tools do you have available?"

### Server Registration Issues
If the server fails to register:
```bash
# Remove and re-add the server
claude mcp remove superdesign -s user
claude mcp add --scope user superdesign /path/to/superdesign/dist/index.js
```

### Build Errors
Ensure you have Node.js 16+ installed:
```bash
node --version  # Should be v16.0.0 or higher
```

## 🤝 Relationship to Superdesign

This MCP server provides a complementary integration for [Superdesign](https://github.com/superdesigndev/superdesign) by [@jasonzhou1993](https://twitter.com/jasonzhou1993) and [@jackjack_eth](https://twitter.com/jackjack_eth).

While Superdesign offers an IDE extension that works across multiple editors, this MCP server specifically enhances Claude Code by:
- **Eliminating the need for API keys** - uses Claude Code's built-in LLM connection
- **Providing native tool integration** - no manual prompt copying required
- **Enabling direct tool calls** - seamless workflow without copy/paste

This addresses the community request for Claude Code API provider support (see [Superdesign Issue #3](https://github.com/superdesigndev/superdesign/issues)).

### How it's Different

| Aspect | Superdesign Extension | This MCP Server |
|--------|----------------------|-----------------|
| **Integration Type** | IDE Extension | Native MCP Tools |
| **Claude Code Access** | Manual prompt copying | Direct tool invocation |
| **API Requirements** | Separate API key needed | Uses Claude Code's existing connection |
| **User Experience** | Copy/paste workflow | Automated orchestration |

## Docker Deployment

### Building the Docker Image Locally

```bash
# Build the image
docker build -t superdesign-mcp-server .

# Run the container
docker run -i \
  -v $(pwd)/superdesign:/workspace/superdesign \
  superdesign-mcp-server
```

### Using Docker Compose

The repository includes a `docker-compose.yml` for easy local development:

```bash
# Start the MCP server
docker-compose up -d

# View logs
docker-compose logs -f superdesign-mcp

# Stop the server
docker-compose down
```

### GitHub Actions CI/CD

The repository includes automated Docker builds via GitHub Actions:

- **Push to `main`**: Builds and publishes to `ghcr.io` with `latest` tag
- **Semantic version tags** (e.g., `v1.0.0`): Creates versioned releases
- **Pull requests**: Builds and tests without publishing

**Available Image Tags:**
- `latest` - Latest stable release from main branch
- `v1.0.0`, `v1.0`, `v1` - Semantic versioned releases
- `main-<sha>` - Commit-specific builds

### Multi-Architecture Support

Docker images are built for multiple architectures:
- `linux/amd64` (Intel/AMD)
- `linux/arm64` (Apple Silicon, ARM servers)

### Volume Mounts

The Docker container expects the following volume mounts:

- `/workspace/superdesign` - Directory where design files are stored
  - `design_iterations/` - Generated designs (HTML/SVG)
  - `design_system/` - Extracted design systems (JSON)

### Environment Variables

Optional environment variables for Docker deployment:

- `NODE_ENV` - Set to `production` (default)
- `WORKSPACE_PATH` - Workspace directory path (default: `/workspace`)

### Security Features

The Docker image includes:
- Non-root user (`mcp:mcp`, UID/GID 1001)
- Minimal Alpine Linux base (~50MB)
- Multi-stage builds for smaller image size
- `dumb-init` for proper signal handling
- Security scanning via Trivy in CI/CD

### Production Deployment

For production deployments, consider:

1. **Volume Persistence**: Ensure design files are persisted
2. **Resource Limits**: Set CPU/memory limits via Docker
3. **Health Checks**: Built-in health check every 30s
4. **Logging**: JSON logging with rotation (10MB, 3 files)

Example production docker-compose:

```yaml
services:
  superdesign-mcp:
    image: ghcr.io/jonthebeef/superdesign-mcp-claude-code:v1.0.0
    restart: unless-stopped
    volumes:
      - ./superdesign:/workspace/superdesign
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## License

This project follows the same license as the original Superdesign project. Please refer to the [Superdesign repository](https://www.superdesign.dev) for license details.