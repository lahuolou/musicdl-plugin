# musicdl-plugin

适用于 **Lnh-Music-Tag** 应用的聚合多平台音乐搜索与下载插件（下载器）。支持网易云 / QQ 音乐 / 酷狗 / 酷我 / 咪咕 / 汽水 / Bilibili 等多平台的音乐搜索与下载，内置可视化控制面板，Windows / macOS / Linux 三平台可用。

## 功能特性

- **多平台聚合搜索**：综合搜索自动聚合多源结果，也可指定单一平台精准搜索
- **多音质下载**：自动识别音质（无损 FLAC / 320k / 192k / 标准），默认附带封面与歌词
- **三平台支持**：Windows / macOS / Linux 一套插件全部覆盖
- **可视化面板**：内置 Web UI，搜索、下载一键操作，明暗主题自适应
- **自定义下载目录**：可手动指定输出目录，留空自动读取宿主默认音乐目录
- **扫码登录自动获取 Cookie**：网易云 / QQ / 酷狗 / B站 手机扫码即登录，Cookie 自动保存到配置
- **可配置 Cookie**：各平台 Cookie 可选填写，用于下载无损 / VIP 等受限歌曲
- **更新检测**：面板内置「检查更新」，对比 GitHub Release 最新版本，发现新版提示一键跳转下载

## 目录结构

```
musicdl-plugin-optimized/
├── plugin.json                     # 插件清单（名称、版本、入口、配置字段）
├── bin/
│   ├── musicdl-plugin-windows.exe  # Windows 可执行文件
│   ├── musicdl-plugin-darwin       # macOS 可执行文件
│   ├── musicdl-plugin-linux        # Linux 可执行文件
│   ├── run.cmd                     # Windows 启动脚本
│   └── run.sh                      # macOS / Linux 启动脚本（按系统自动选择）
└── ui/
    └── index.html                  # Web 控制面板
```

## 安装与接入

本插件适用于 **Lnh-Music-Tag** 应用，通过后台导入 ZIP 插件包安装：

1. 登录 **Lnh-Music-Tag** 后台
2. 进入「插件管理」
3. 选择「导入 ZIP 插件」，上传插件 ZIP 包

ZIP 包内应包含 `plugin.json`（插件清单）、`bin/`（三平台可执行文件与启动脚本）、`ui/`（Web 控制面板），应用读取 `plugin.json` 后即注册为「下载器」工具插件：

- **Windows**：入口为 `bin/run.cmd`，调用 `musicdl-plugin-windows.exe`
- **macOS**：入口为 `bin/run.sh`，自动调用 `musicdl-plugin-darwin`
- **Linux**：入口为 `bin/run.sh`，自动调用 `musicdl-plugin-linux`

## 配置说明

在宿主的插件设置中可配置以下字段：

| 字段 | 说明 | 必填 |
| --- | --- | --- |
| `default_dir` | 默认下载目录，留空则自动读取宿主默认音乐目录 | 否 |
| `netease_cookie` | 网易云 Cookie，下载无损 / VIP 歌曲时填写；可在面板扫码登录自动获取 | 否 |
| `qq_cookie` | QQ 音乐 Cookie；可在面板扫码登录自动获取 | 否 |
| `kugou_cookie` | 酷狗 Cookie；可在面板扫码登录自动获取 | 否 |
| `kuwo_cookie` | 酷我 Cookie | 否 |
| `migu_cookie` | 咪咕 Cookie | 否 |
| `bilibili_cookie` | B 站 Cookie；可在面板扫码登录自动获取 | 否 |

## 使用方法

1. 打开插件面板，选择搜索源（综合搜索或指定平台）
2. 输入歌名 / 歌手，回车或点击「搜索」
3. 在结果列表中点击「下载」，默认自动保存封面与歌词
4. 下载目录留空时使用宿主默认音乐目录

### 扫码登录（获取无损 / VIP 下载权限）

1. 在面板上方选择平台（网易云 / QQ音乐 / 酷狗 / B站），点击「扫码登录」
2. 用对应平台的手机 App 扫描二维码并确认登录
3. 登录成功后 Cookie 自动保存到插件配置，面板搜索 / 下载即自动携带
4. 面板会显示当前已登录的平台；下载无损（FLAC）需该账号为对应平台 VIP/会员

### 检查更新

1. 点击面板右上角「检查更新」，插件通过 GitHub Releases API 对比最新版本
2. 有新版本时自动打开 Release 页面
3. 下载新 ZIP 后在宿主「插件管理」重新导入（覆盖导入）即完成升级，已配置的 Cookie 保留

## 接口约定

面板通过 `POST /api/plugins/musicdl.downloader/run` 调用插件，请求需携带请求头 `X-Requested-With: Lnh-Music-Tag`。

| 操作 | 请求体示例 | 说明 |
| --- | --- | --- |
| 综合搜索 | `{"op": "search_all", "keyword": "周杰伦"}` | 聚合多源搜索结果 |
| 单源搜索 | `{"op": "search", "source": "netease", "keyword": "周杰伦"}` | 指定平台搜索 |
| 下载 | `{"op": "download", "song": {...}, "out_dir": "D:/Music", "with_cover": true, "with_lyrics": true}` | 下载歌曲（含封面/歌词） |
| 创建扫码登录 | `{"op": "login_create", "source": "netease"}` | 返回二维码（base64 PNG）与 key |
| 轮询登录状态 | `{"op": "login_poll", "source": "netease", "key": "..."}` | 返回状态；success 时含 cookie |
| 检查更新 | `{"op": "check_update"}` | 返回 current / latest / has_update / url |

单源搜索的 `source` 可选值：`netease`（网易云）、`qq`（QQ 音乐）、`kugou`（酷狗）、`kuwo`（酷我）、`migu`（咪咕）、`soda`（汽水）、`bilibili`（B 站）。

扫码登录的 `source` 支持：`netease`、`qq`、`kugou`、`bilibili`（music-lib 提供扫码能力）。

## 版本历史

| 版本 | 说明 |
| --- | --- |
| v1.1.0 | 新增扫码登录（网易云/QQ/酷狗/B站）自动获取 Cookie、面板调用自动携带已配置 Cookie、内置更新检测（对齐宿主多源版本检查机制） |
| v1.0.0 | 初始发布：多平台聚合搜索与下载、内置 Web UI、三平台支持、多平台 Cookie 配置 |

## 免责声明

本项目仅供个人学习与交流使用。歌曲版权归各音乐平台及相关权利人所有，请尊重音乐版权，请勿将下载内容用于商业用途。
