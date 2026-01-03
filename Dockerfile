# Multi-stage build for MkDocs documentation

# Stage 1: Build documentation
FROM python:3.11-slim AS builder

WORKDIR /docs

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy documentation source
COPY . .

# Build static documentation
RUN mkdocs build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built documentation from builder stage
COPY --from=builder /docs/site /usr/share/nginx/html

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
