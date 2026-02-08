#!/bin/bash
#
# Nginx 预编译脚本 for X-Panel
#
# 用法: ./build.sh <nginx_version>
# 示例: ./build.sh 1.26.2
#
set -e

NGINX_VERSION="${1:-1.26.2}"
INSTALL_PREFIX="/opt/xpanel/nginx"
OUTPUT_DIR="$(pwd)/output"

echo "============================================"
echo "  Building Nginx ${NGINX_VERSION}"
echo "  Target prefix: ${INSTALL_PREFIX}"
echo "  Output: ${OUTPUT_DIR}"
echo "  Arch: $(uname -m)"
echo "============================================"

# Create build directory
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

# Download source
echo ">>> Downloading nginx-${NGINX_VERSION}..."
wget -q "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"

if [ ! -f "nginx-${NGINX_VERSION}.tar.gz" ]; then
    echo "ERROR: Failed to download nginx-${NGINX_VERSION}.tar.gz"
    exit 1
fi

tar -xzf "nginx-${NGINX_VERSION}.tar.gz"
cd "nginx-${NGINX_VERSION}"

# Configure
echo ">>> Configuring..."
./configure \
    --prefix=${INSTALL_PREFIX} \
    --sbin-path=${INSTALL_PREFIX}/sbin/nginx \
    --modules-path=${INSTALL_PREFIX}/modules \
    --conf-path=${INSTALL_PREFIX}/conf/nginx.conf \
    --pid-path=${INSTALL_PREFIX}/logs/nginx.pid \
    --error-log-path=${INSTALL_PREFIX}/logs/error.log \
    --http-log-path=${INSTALL_PREFIX}/logs/access.log \
    --lock-path=${INSTALL_PREFIX}/logs/nginx.lock \
    --http-client-body-temp-path=${INSTALL_PREFIX}/temp/client_body \
    --http-proxy-temp-path=${INSTALL_PREFIX}/temp/proxy \
    --http-fastcgi-temp-path=${INSTALL_PREFIX}/temp/fastcgi \
    --http-uwsgi-temp-path=${INSTALL_PREFIX}/temp/uwsgi \
    --http-scgi-temp-path=${INSTALL_PREFIX}/temp/scgi \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-pcre

# Build
NPROC=$(nproc 2>/dev/null || echo 2)
echo ">>> Compiling with ${NPROC} cores..."
make -j${NPROC}

# Install to staging directory
echo ">>> Installing to staging directory..."
make install DESTDIR="${BUILD_DIR}/staging"

# Copy staged files to output
mkdir -p "${OUTPUT_DIR}"
cp -r "${BUILD_DIR}/staging${INSTALL_PREFIX}/"* "${OUTPUT_DIR}/"

# Create additional directories
mkdir -p "${OUTPUT_DIR}/conf/conf.d"
mkdir -p "${OUTPUT_DIR}/conf/ssl"
mkdir -p "${OUTPUT_DIR}/temp/client_body"
mkdir -p "${OUTPUT_DIR}/temp/proxy"
mkdir -p "${OUTPUT_DIR}/temp/fastcgi"
mkdir -p "${OUTPUT_DIR}/temp/uwsgi"
mkdir -p "${OUTPUT_DIR}/temp/scgi"

# Ensure correct permissions
chmod +x "${OUTPUT_DIR}/sbin/nginx"

# Clean up
cd /
rm -rf "$BUILD_DIR"

echo ""
echo "============================================"
echo "  Build complete!"
echo "============================================"
echo "Output directory: ${OUTPUT_DIR}"
ls -lh "${OUTPUT_DIR}/sbin/nginx"
echo ""
echo "Nginx version info:"
"${OUTPUT_DIR}/sbin/nginx" -V 2>&1 || true
echo ""
