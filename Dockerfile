# Multi-stage build for optimal image size
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY src ./src

# Build TypeScript
RUN npm install -D typescript @types/node && \
    npm run build

# Production stage
FROM node:20-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S mcp && \
    adduser -u 1001 -S mcp -G mcp

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production && \
    npm cache clean --force

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Copy superdesign directory structure (will be mounted)
RUN mkdir -p /workspace/superdesign/design_iterations && \
    mkdir -p /workspace/superdesign/design_system && \
    chown -R mcp:mcp /workspace

# Switch to non-root user
USER mcp

# Set environment variables
ENV NODE_ENV=production
ENV WORKSPACE_PATH=/workspace

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "console.log('healthy')" || exit 1

# Default command - MCP servers use stdio transport
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "dist/index.js"]

# Labels for GitHub Container Registry
LABEL org.opencontainers.image.source="https://github.com/jonthebeef/superdesign-mcp-claude-code"
LABEL org.opencontainers.image.description="Superdesign MCP Server - AI design agent for Claude Code"
LABEL org.opencontainers.image.licenses="MIT"
