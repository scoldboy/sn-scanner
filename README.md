# SN 扫码录入（手机端）

用手机摄像头扫配件上的二维码 / 一维条码，按类别收集 SN 码，导出一段文字，
粘贴到电脑「装机记账管理」配置单的「粘贴导入 SN」里，自动回填各配件行的串码。

纯前端、无后端、无数据库：扫码记录只存在手机浏览器 `localStorage`，导出即复制文字。

## 目录结构

```
sn-scanner/
├── index.html        # 手机端页面（自包含，含 UI + 扫码逻辑）
├── zxing.min.js      # ZXing 解码库（离线打包，二维码+一维条码通吃）
├── nginx.conf        # 仅 443 HTTPS 的站点配置
├── Dockerfile        # nginx:alpine + 自签名证书
├── docker-compose.yml
└── README.md
```

## 部署到 DPANEL（Home Assistant 的 Docker 面板）

> 摄像头需要 HTTPS 或 localhost 才可用。本镜像**内置自签名证书走 HTTPS**，
> 因此手机用 `http://` 打不开摄像头，必须用 `https://`。首次打开会提示证书不受信任，
> 点「继续 / 高级 → 继续访问」即可（这是自签名证书的正常现象）。

**方式 A：DPANEL 从 Dockerfile 构建（推荐）**
1. 把整个 `sn-scanner/` 文件夹传到 HA 主机（或放进一个 git 仓库）。
2. 打开 DPANEL → 镜像 → **创建镜像**，选择「从 Dockerfile 构建」，上下文指向 `sn-scanner/` 目录。
3. 创建容器时端口映射：`容器端口 443` → `主机端口 8808`（或任意空闲端口）。
4. 启动容器。

**方式 B：HA 主机本地 build 后导入**
```bash
cd sn-scanner
docker build -t sn-scanner .
# 然后在 DPANEL 里「导入镜像 / load」该镜像，或：
docker run -d --name sn-scanner -p 8808:443 --restart unless-stopped sn-scanner
# 或用 compose： docker compose up -d
```

## 手机使用

1. 手机与 HA 同一 WiFi，浏览器打开 `https://<HA的局域网IP>:8808`
   （例如 `https://192.168.31.233:8808`）。
2. 点右上「⚙ 类别」可增删类别（默认与配置单一致：CPU/主板/散热/内存/显卡/硬盘/电源/机箱/风扇/其他）。
3. 选好当前类别 → 「开始扫码」→ 对准配件码；可继续扫同类别，或切类别扫下一种。
4. 扫完点「导出并复制」，文字已进剪贴板（也可长按文本框手动复制）。

导出格式示例：
```
===SN-IMPORT:v1===
显卡: ABC123
显卡: DEF456
内存: MEM789
===END===
```

## 配置单导入端（电脑端）

在「装机记账管理」装配工单的「配件明细」区点 **📷 粘贴导入SN**，
把上面那段文字粘进去 → 「导入」。按类别匹配配件行的「串码/备注」空框填入；
同类别多个 SN 用逗号拼接进同一行。

## 说明 / 局限

- 自签名证书每隔 10 年需重新 build（或你换成受信任证书）。
- 手机端记录仅存本地浏览器；换浏览器/清缓存会丢失，重要数据请及早在配置单落库。
- 若你已有 HA 域名 / Nabu Casa 等 HTTPS 反代，可不用自签证书：把 `nginx.conf` 改回 80、
  由反代转发即可（此版本默认自签，零额外基建）。
