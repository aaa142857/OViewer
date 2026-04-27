# OViewer

Flutter 跨平台漫画阅读器，兼容 iOS 11+，参照 [EhPanda](https://github.com/EhPanda-Team/EhPanda) 设计。

## 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter 3.16.0 / Dart 3.2 |
| 状态管理 | flutter_bloc 8.x + equatable |
| 依赖注入 | get_it |
| 网络 | dio 5.x + cookie_jar |
| 数据解析 | html (HTML→Model) |
| 本地存储 | drift (SQLite) + shared_preferences |
| 图片 | cached_network_image + photo_view |
| CI/CD | GitHub Actions (macOS runner → unsigned IPA) |

## 项目结构

```
lib/
├── main.dart                    # 入口 + DI 注册
├── app.dart                     # MaterialApp + BlocProvider
├── core/
│   ├── constants/               # AppConstants, ApiEndpoints
│   ├── network/                 # DioClient, CookieManager, ApiException
│   ├── parser/                  # HTML 解析器 (列表/详情/图片/搜索)
│   ├── storage/                 # drift 数据库, SharedPreferences
│   ├── router/                  # 路由表
│   └── theme/                   # 亮色/暗色主题
├── models/                      # 数据模型 (9 个)
├── repositories/                # 数据仓库层 (8 个)
├── blocs/                       # BLoC 状态管理 (9 组 event/state/bloc)
├── widgets/                     # 可复用组件 (8 个)
└── screens/                     # 页面 (9 个)
```

## 功能列表

### P0 — 核心功能
- [x] 画廊列表浏览（Latest / Popular / Watched / Favorites Tab）
- [x] 列表视图 + 瀑布流视图切换，Shimmer 骨架屏加载
- [x] 关键词搜索 + 分类筛选 + 最低评分筛选 + 搜索历史
- [x] 画廊详情（封面 Hero 动画、元数据、标签分组、评论、缩略图预览）
- [x] 漫画阅读器（左右翻页 / 右左翻页 / 垂直连续滚动，PhotoView 缩放，预加载）
- [x] Cookie 登录（WebView 自动提取 + 手动输入）
- [x] 收藏管理（本地 SQLite + 云端同步）
- [x] 浏览历史（自动记录 + 阅读进度条）

### P1 — 增强功能
- [x] 标签翻译（EhTagTranslation 中文翻译，自动缓存）
- [x] 下载管理（后台队列，暂停/恢复，进度追踪）
- [x] 设置中心（主题、缓存管理、代理配置、阅读偏好）
- [x] 阅读器缩略图条快速跳页

### P2 — 完善功能
- [x] 画廊评分对话框
- [x] 评论投票（赞/踩）
- [x] E-Hentai / ExHentai 多站点切换
- [x] Hero 过渡动画
- [x] 单元测试 + BLoC 测试（25 个用例）

## 环境要求

- Flutter 3.16.0+
- Dart 3.2.0+
- Android Studio / VS Code
- (iOS 编译) GitHub Actions

## 快速开始

```bash
# 1. 克隆项目
git clone <repo-url>
cd o_viewer

# 2. 安装依赖
flutter pub get

# 3. 生成 drift 数据库代码
dart run build_runner build --delete-conflicting-outputs

# 4. 运行 (Android 模拟器 / 真机)
flutter run

# 5. 运行测试
flutter test

# 6. 静态分析
flutter analyze
```

## 测试

### 运行全部测试
```bash
flutter test
```

### 运行单个测试文件
```bash
flutter test test/parser/gallery_list_parser_test.dart
flutter test test/blocs/gallery_list_bloc_test.dart
flutter test test/blocs/auth_bloc_test.dart
```


### 手动验证
```
在 app 上手动验证：
- 首页是否加载画廊列表
- 搜索是否返回结果
- 详情页标签、评分、评论是否正常显示
- 阅读器翻页、缩放、模式切换
- 登录/登出流程
- 收藏添加/删除
- 历史记录是否自动更新
```

### 测试覆盖范围

| 模块 | 测试文件 | 用例数 | 说明 |
|------|---------|--------|------|
| GalleryListParser | `test/parser/gallery_list_parser_test.dart` | 5 | 评分解析、分页、HTML 解析、数字提取 |
| GalleryDetailParser | `test/parser/gallery_detail_parser_test.dart` | 3 | 缩略图提取、元数据解析、缺失字段处理 |
| GalleryImageParser | `test/parser/gallery_image_parser_test.dart` | 5 | showkey、pageToken、API URL、图片尺寸 |
| GalleryListBloc | `test/blocs/gallery_list_bloc_test.dart` | 4 | 加载、错误、分页、边界 |
| SearchBloc | `test/blocs/search_bloc_test.dart` | 3 | 搜索、清空、历史 |
| AuthBloc | `test/blocs/auth_bloc_test.dart` | 4 | 登录检查、Cookie 登录、登出 |

## 构建 iOS IPA

### 本地构建 (需要 macOS)
```bash
flutter build ios --release --no-codesign
```

### GitHub Actions 自动构建
推送到 `main` 分支或打 `v*` 标签时自动触发：
- 构建产物在 Actions → Artifacts 下载
- 打 tag 时自动创建 GitHub Release

### 安装到 iOS 设备
通过以下方式安装：
1. **AltStore** — 推荐，使用 Apple ID 自签名
2. **Sideloadly** — 同上，GUI 工具
3. **TrollStore** — 如果设备支持（iOS 14.0-16.6.1）

## iOS 11 兼容性说明

- `flutter_inappwebview` 锁定 `^5.8.0`（6.x 需要 iOS 13+）
- 不使用 Firebase（需要 iOS 13+）
- `ios/Podfile` 强制所有 Pod 部署目标为 `11.0`
- 所有依赖包均验证兼容 iOS 11

## 许可证

MIT
