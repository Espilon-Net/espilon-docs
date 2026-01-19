# Stage 1: Build MkDocs
FROM python:3.11-slim AS builder
WORKDIR /docs

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN mkdocs build --clean

# Stage 2: Serve with nginx on 8008
FROM nginx:alpine

COPY --from=builder /docs/site /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8008

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8008/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
