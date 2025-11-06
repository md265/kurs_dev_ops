FROM nginx:1.27.3

LABEL maintainer="asdf"

ENV NINJA_NGINX_VERSION="0.1"

ARG DEST_FILE="index.html"

RUN apt-get update && \
    apt-get install -y \
    iproute2 \
    wget \
    && rm -rf /var/lib/apt/lists/

COPY index.html /usr/share/nginx/html/${DEST_FILE}
