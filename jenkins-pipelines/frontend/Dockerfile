FROM nginx:alpine

# Install useful network/debug tools
RUN apk update && apk add --no-cache \
    vim \
    bash \
    busybox-extras \
    net-tools \
    bind-tools \
    curl \
    tcpdump

# Copy custom index.html to nginx web root
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Default CMD is fine for nginx:alpine
