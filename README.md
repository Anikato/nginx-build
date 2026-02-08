# Nginx Build for X-Panel

预编译 Nginx 二进制文件，供 [X-Panel](https://github.com/Anikato/x-panel) 使用。

## 工作原理

1. 推送 `v*` 标签（如 `v1.26.2`）触发 GitHub Actions 自动编译
2. CI 为 `amd64` 和 `arm64` 两个架构编译 Nginx
3. 编译产物发布为 GitHub Release

## 编译模块

```
--with-http_ssl_module
--with-http_v2_module
--with-http_realip_module
--with-http_gzip_static_module
--with-http_stub_status_module
--with-stream
--with-stream_ssl_module
--with-pcre
```

## 发布新版本

```bash
# 编译 Nginx 1.26.2
git tag v1.26.2
git push origin v1.26.2

# 编译 Nginx 1.27.0
git tag v1.27.0
git push origin v1.27.0
```

也可以在 GitHub Actions 页面手动触发 `workflow_dispatch`，输入版本号即可。

## 手动使用

```bash
# 下载
curl -LO https://github.com/Anikato/nginx-build/releases/download/v1.26.2/nginx-1.26.2-linux-amd64.tar.gz

# 解压到 X-Panel 的 Nginx 目录
mkdir -p /opt/xpanel/nginx
tar -xzf nginx-1.26.2-linux-amd64.tar.gz -C /opt/xpanel/nginx

# 验证
/opt/xpanel/nginx/sbin/nginx -v
```

## 目录结构

解压后的目录结构：

```
nginx/
├── sbin/nginx          # 主程序
├── conf/
│   ├── nginx.conf      # 主配置
│   ├── conf.d/         # 站点配置
│   ├── ssl/            # SSL 证书
│   ├── mime.types
│   ├── fastcgi.conf
│   └── ...
├── html/               # 默认页面
├── logs/               # 日志 + PID
└── temp/               # 临时文件
    ├── client_body/
    ├── proxy/
    └── fastcgi/
```
