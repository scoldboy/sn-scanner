# SN 扫码录入 - Docker 镜像
# 基于 nginx:alpine，内置自签名 HTTPS 证书，手机浏览器通过 https 访问即可调用摄像头。
FROM nginx:alpine

# 生成自签名证书（有效期 10 年，内部工具足够；如更换域名/被拦截可重新 build）
RUN apk add --no-cache openssl \
    && mkdir -p /etc/nginx/certs \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
        -keyout /etc/nginx/certs/server.key \
        -out /etc/nginx/certs/server.crt \
        -subj "/C=CN/ST=Local/L=Local/O=AwayDiyBook/CN=sn-scanner"

# 静态资源
COPY index.html   /usr/share/nginx/html/index.html
COPY zxing.min.js /usr/share/nginx/html/zxing.min.js

# 站点配置（覆盖默认 80 端口配置，仅保留 443 HTTPS）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443
