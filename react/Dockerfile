# ============================================
# DOCKERFILE OTIMIZADO - REACT + VITE + NGINX
# Best Practices 2025 - GPS IT Services
# ============================================

# ============================================
# Stage 1: Build da aplicação
# ============================================
FROM node:22-slim AS builder

# Metadata labels (OCI standard)
LABEL org.opencontainers.image.title="React Vite Application"
LABEL org.opencontainers.image.description="Production-ready React application built with Vite"
LABEL org.opencontainers.image.vendor="GPS IT Services"
LABEL org.opencontainers.image.authors="Vaz <vaz@gpsitservicos.com.br>"
LABEL maintainer="GPS IT Services"

# Set working directory
WORKDIR /app

# Install only required dependencies for build
# Combine RUN commands to reduce layers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm@latest

# Copy package files first (better layer caching)
COPY package.json package-lock.json* ./

# Install dependencies with clean install for reproducibility
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# Copy source code
COPY . .

# Build application for production
# Environment variables for build optimization
ENV NODE_ENV=production
ENV VITE_BUILD_TARGET=production
RUN npm run build

# ============================================
# Stage 2: Production image com Nginx
# ============================================
FROM nginx:1.27-alpine

# Metadata labels
LABEL org.opencontainers.image.title="React Vite Application - Production"
LABEL org.opencontainers.image.description="Nginx serving React application"
LABEL org.opencontainers.image.vendor="GPS IT Services"

# Install curl for healthchecks and security updates
RUN apk add --no-cache \
    curl \
    tzdata \
    && rm -rf /var/cache/apk/*

# Set timezone
ENV TZ=America/Sao_Paulo

# Create non-root user for Nginx
RUN addgroup -g 10001 -S nginx-app && \
    adduser -S -D -H -u 10001 -h /var/cache/nginx -s /sbin/nologin -G nginx-app -g nginx-app nginx-app

# Remove default nginx config and content
RUN rm -rf /usr/share/nginx/html/* && \
    rm /etc/nginx/conf.d/default.conf

# Copy built application from builder stage
COPY --from=builder --chown=nginx-app:nginx-app /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY --chown=nginx-app:nginx-app nginx.conf /etc/nginx/conf.d/default.conf

# Adjust permissions
RUN chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chmod -R 755 /usr/share/nginx/html && \
    # Create pid file directory
    mkdir -p /var/run && \
    chown -R nginx-app:nginx-app /var/run

# Create nginx.pid with correct permissions
RUN touch /var/run/nginx.pid && \
    chown nginx-app:nginx-app /var/run/nginx.pid

# Switch to non-root user
USER nginx-app

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
