# SN 扫码录入（手机端）

用手机扫配件上的二维码 / 一维条码，按类别收集 SN 码，导出一段文字，
粘贴到电脑「装机记账管理」配置单的「粘贴导入 SN」里，自动回填各配件行的串码。

纯前端、无后端、无数据库：扫码记录只存在手机浏览器 `localStorage`，导出即复制文字。
**无需 Docker、无需服务器**——本页是纯静态文件，挂到任意免费 HTTPS 静态空间即可，
也可直接发到手机用「从相册选图识别」。

## 目录结构

```
sn-scanner/
├── index.html        # 手机端页面（自包含，含 UI + 扫码逻辑）
├── zxing.min.js      # ZXing 解码库（离线打包，二维码+一维条码通吃）
├── nginx.conf / Dockerfile / docker-compose.yml   # 旧版自托管方案，可忽略
└── README.md
```

## 两种用法

### 用法一：挂在免费 HTTPS 静态空间（推荐，实时摄像头可用）
> 浏览器**实时摄像头**必须 HTTPS 或 localhost 才给开。免费静态托管都自带 HTTPS，直接解决。

任选一个（都免费、都自动 HTTPS）：

- **GitHub Pages（最简单，仓库需设为 Public）**
  1. 在 GitHub 仓库 `scoldboy/sn-scanner` → Settings → 勾选 Public。
  2. Settings → Pages → Source 选 `main` 分支 / root → Save。
  3. 约 1 分钟后访问 `https://scoldboy.github.io/sn-scanner/`。

- **Netlify / Cloudflare Pages（仓库可保持 Private）**
  1. 注册 Netlify 或 Cloudflare Pages，登录时授权 GitHub。
  2. 选 `scoldboy/sn-scanner` 仓库 → 部署（Build command 留空，Publish directory 填 `/` 或 `.`）。
  3. 得到 `https://xxx.netlify.app` 之类地址，手机打开即可。

手机与电脑微信/同设备互传都行，只要手机浏览器是 `https://` 开头就能调摄像头。

### 用法二：零托管，手机直接打开 HTML（相册识别）
不想挂任何服务：把 `index.html` + `zxing.min.js` 两个文件发到手机（微信文件传输/网盘/AirDrop），
用手机浏览器打开 `index.html` → 点 **「🖼 从相册选图识别」** → 拍照或选相册里条码照片 → 自动解出 SN。
（此模式下实时摄像头不可用，用「选图识别」代替，同样能录 SN。）

## 手机使用

1. 打开页面后，点右上「⚙ 类别」可增删类别（默认与配置单一致：
   CPU / 主板 / 散热 / 内存 / 显卡 / 硬盘 / 电源 / 机箱 / 风扇 / 其他）。
   **类别必须和配置单设置里的 `sale_categories` 对上**，否则导入时提示「无空行」。
2. 选好当前类别：
   - 在 HTTPS 环境下 → 「📷 开始扫码」实时对准配件码；
   - 直接打开文件时 → 「🖼 从相册选图识别」拍照/选图。
3. 可继续扫同类别，或切类别扫下一种；也能在输入框手动补录。
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

- 手机端记录仅存本地浏览器；换浏览器/清缓存会丢失，重要数据请及早在配置单落库。
- 选图识别一次解一个码；一图多码时重拍分多次即可。
- `nginx.conf` / `Dockerfile` / `docker-compose.yml` 是旧版自托管方案，已不再需要，留着无害。
