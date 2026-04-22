# Calcite —— 基于 Web 与 Android 双端的智能笔记系统

> 本文档面向 AI Coding Agent，帮助 Agent 在零背景知识下快速理解整个 Calcite 项目的架构、技术栈、构建方式与开发规范。
> 
> 项目采用中文作为主要注释与文档语言。

---

## 项目概述

Calcite 是一个跨平台的智能笔记管理系统，包含 **Web 前端**、**Android 客户端** 与 **C++ 后端服务** 三个子项目。三个子项目以 Git 子模块（submodule）形式组织在根仓库中：

| 子模块 | 路径 | 技术栈 | 说明 |
|--------|------|--------|------|
| 后端服务 | `calcite_server/` | Drogon (C++17/20) + MariaDB + ES + MinIO | RESTful API 服务端 |
| Web 前端 | `calcite_web/` | Vue 3 + Vite + Pinia + Element Plus | 三栏式笔记管理 SPA |
| Android | `calcite_android/` | Kotlin + Jetpack (Room/Navigation/WorkManager) | 移动端笔记 App |

根仓库仅负责聚合三个子模块，本身无业务代码。日常开发在各子模块目录内独立进行。

---

## 技术栈与运行时架构

### 后端 (`calcite_server/`)

- **框架**：Drogon C++ Web 框架（C++17/20）
- **数据库**：MariaDB（MySQL 兼容），通过 Drogon ORM 操作
- **全文搜索**：Elasticsearch 8.12.2，使用 IK 中文分词器
- **文件存储**：MinIO（Docker 部署，S3 兼容对象存储）
- **AI 服务**：调用 DeepSeek / Kimi 等在线 API 实现 AI 标签生成与 OCR
- **认证**：JWT（`Authorization: Bearer {token}`）
- **构建**：CMake 3.5+
- **端口**：`8888`

### Web 前端 (`calcite_web/calcite-web/`)

- **框架**：Vue 3.5.24，Composition API（`<script setup>`）
- **构建工具**：Vite 7.2.4
- **路由**：Vue Router 4.6.4
- **状态管理**：Pinia 3.0.4（Setup Store 模式）
- **UI 组件库**：Element Plus 2.13.7
- **Markdown 编辑器**：md-editor-v3 6.4.2
- **HTTP 客户端**：Axios 1.13.2
- **测试**：Vitest 4.1.4 + @vue/test-utils + jsdom
- **类型**：TypeScript 渐进式迁移（核心类型定义在 `src/types/`）
- **主题**：Everforest 深色/浅色，CSS 变量驱动
- **代理**：开发时 Vite 将 `/api` 代理到 `http://localhost:8888`

### Android (`calcite_android/app/`)

- **语言**：Kotlin 2.0.21，JVM 11
- **Min SDK**：24，**Target/Compile SDK**：36
- **构建**：Gradle Kotlin DSL，AGP 8.13.0
- **架构**：MVVM（ViewModel + LiveData）+ Repository 模式
- **导航**：Jetpack Navigation Component
- **网络**：Retrofit 2.11.0 + OkHttp 4.12.0 + Gson
- **本地数据库**：Room 2.7.1（KSP 注解处理）
- **偏好存储**：DataStore 1.1.4
- **后台同步**：WorkManager 2.10.0
- **Markdown 渲染**：Markwon 4.6.2
- **图片加载**：Coil 2.5.0
- **UI**：XML Layout + ViewBinding

---

## 项目结构

```
calcite/                          # 根仓库（仅聚合子模块）
├── calcite_server/               # 后端子模块（独立 Git 仓库）
│   ├── calcite/                  # 服务主目录
│   │   ├── CMakeLists.txt
│   │   ├── config.json           # Drogon 服务配置（端口、DB、线程数）
│   │   ├── main.cc               # 程序入口
│   │   ├── controllers/          # API 控制器（Auth/Note/File/Folder/Tag/OCR/Recommend/User）
│   │   ├── models/               # ORM 模型（由 drogon_ctl 生成）
│   │   ├── services/             # 业务逻辑层（Auth/NoteFolder/OCR/Kimi/Ds）
│   │   ├── utils/                # 工具类（EsClient/JwtUtil/MinioClient/PasswordUtil）
│   │   └── test/                 # 测试目录（CMake 子项目 calcite_test）
│   ├── docs/
│   │   ├── schema.md             # 数据库表结构设计（13 张核心表）
│   │   └── api.md                # REST API 完整文档
│   ├── commands.sh               # 常用命令与环境搭建脚本
│   └── Readme.md
│
├── calcite_web/                  # Web 前端子模块（独立 Git 仓库）
│   ├── calcite-web/              # 前端项目根目录
│   │   ├── package.json
│   │   ├── vite.config.js        # Vite 配置（含代理、代码分割）
│   │   ├── vitest.config.js      # 测试配置
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── main.js           # 应用入口
│   │       ├── App.vue           # 根组件
│   │       ├── api/              # API 接口层（auth/note/folder/file/ocr/user）
│   │       ├── components/       # 组件（center/sidebar/dialogs/FileTree）
│   │       ├── composables/      # 组合式函数（useTheme）
│   │       ├── router/           # 路由配置
│   │       ├── stores/           # Pinia Store（user/layout/folder/note/file/dialog）
│   │       ├── styles/           # 主题配置（theme.js/theme.css）
│   │       ├── types/            # TypeScript 类型定义
│   │       ├── utils/            # 工具（request.js Axios 封装）
│   │       └── views/            # 页面视图（Login/Register/Home）
│   ├── docs/                     # 开发文档与迭代记录（260*.md 按日期命名）
│   ├── AGENTS.md                 # Web 端专属 Agent 文档
│   └── Readme.md
│
├── calcite_android/              # Android 子模块（独立 Git 仓库）
│   ├── app/
│   │   ├── build.gradle.kts      # 模块构建配置
│   │   └── src/main/java/com/calcite/notes/
│   │       ├── MainActivity.kt
│   │       ├── data/
│   │       │   ├── local/        # Room 数据库（Entity/Dao/Database）+ DataStore
│   │       │   ├── remote/       # Retrofit API 接口 + OkHttp 拦截器
│   │       │   ├── repository/   # Repository 层（按模块划分）
│   │       │   └── sync/         # WorkManager 同步任务
│   │       ├── model/            # 数据模型（Kotlin data class）
│   │       ├── ui/               # UI 层（Fragment/ViewModel）
│   │       │   ├── home/
│   │       │   ├── login/
│   │       │   ├── register/
│   │       │   └── main/         # 笔记列表/编辑器/搜索/工具面板/树形适配器
│   │       └── utils/            # 工具类（NetworkUtils/Result 包装）
│   ├── gradle/libs.versions.toml # 版本目录（Catalog）
│   ├── build.gradle.kts          # 项目级构建配置
│   └── docs/                     # Android 端开发文档
│
├── commands.sh                   # 根仓库 Git 操作记录（历史脚本）
└── Readme.md                     # 项目总览
```

---

## 构建与运行命令

### 后端

```bash
cd calcite_server/calcite
mkdir -p build && cd build
cmake ..
make -j$(nproc)
# 运行
./calcite
```

测试目标：
```bash
cd build
make calcite_test
./test/calcite_test
```

> 依赖：Drogon、libjsoncpp、libuuid、OpenSSL、zlib、libcurl（均需在系统中预先安装）。

### Web 前端

```bash
cd calcite_web/calcite-web

# 安装依赖
npm install

# 开发服务器（代理到 localhost:8888）
npm run dev

# 生产构建
npm run build

# 运行单元测试
npm run test:run

# 预览生产构建
npm run preview
```

### Android

```bash
cd calcite_android

# 编译
./gradlew build

# 单元测试
./gradlew test

# 安装调试 APK
./gradlew installDebug
```

---

## 代码组织与模块划分

### 后端模块

| 目录 | 职责 |
|------|------|
| `controllers/` | 接收 HTTP 请求，参数校验，调用 Service，返回 JSON |
| `services/` | 业务逻辑：认证、笔记文件夹、OCR、AI 调用（Kimi/Ds） |
| `models/` | Drogon ORM 自动生成的数据库模型类 |
| `utils/` | 基础设施：ES 客户端、MinIO 客户端、JWT 工具、密码哈希 |

数据流：**Controller → Service → Model/Utils → MariaDB/ES/MinIO**

### Web 前端模块

| 目录 | 职责 |
|------|------|
| `api/` | 按业务域封装的 API 函数，统一使用 `request.js` |
| `components/` | 可复用组件，按区域分为 `center/`、`sidebar/`、`dialogs/` |
| `stores/` | Pinia Store，按业务域拆分（user/layout/folder/note/file/dialog） |
| `composables/` | 组合式逻辑（主题切换） |
| `views/` | 页面级视图（Login/Register/Home） |

数据流：**组件 → Store → API (`request.js`) → 后端**

### Android 模块

| 目录 | 职责 |
|------|------|
| `data/remote/` | Retrofit 接口定义、OkHttp 拦截器（Token 注入） |
| `data/local/` | Room Entity/Dao、AppDatabase、DataStore 封装 |
| `data/repository/` | 仓库层，聚合本地与远程数据源 |
| `data/sync/` | WorkManager 后台同步逻辑 |
| `ui/` | Fragment + ViewModel，按页面分组 |
| `model/` | 纯数据类（Request/Response/Entity） |

数据流：**UI (Fragment) → ViewModel → Repository → Remote/Local**

---

## 开发规范

### 语言与注释

- **所有注释、文档、变量命名均以中文为主**（如 `editingNote`、`saveStatus`、`folder_id`）。
- 提交信息使用中文或英文均可，但需简洁明了。

### 后端（C++ / Drogon）

- 使用 `drogon_ctl` 生成控制器与模型，保持与 Drogon ORM 规范一致。
- 模型类**不要手写**，应通过 `drogon_ctl create model .` 生成。
- 统一响应格式：`{"code": 0, "message": "...", "data": {...}}`，`code=0` 表示成功。
- 控制器负责参数解析与响应组装，业务逻辑下沉到 Service。
- ES 同步采用**先写数据库、后异步同步 ES** 策略，ES 失败不得阻塞主流程。

### Web 前端（Vue 3）

- 组件使用 `<script setup>` 语法。
- 样式使用 `<style scoped>`，优先使用项目 CSS 变量（`--bg-primary`、`--text-primary` 等）确保主题兼容。
- 覆盖 Element Plus 或 md-editor-v3 时使用 `:deep()`。
- API 调用统一使用 `src/utils/request.js` 导出的 Axios 实例，错误由拦截器统一处理。
- 新增组件按功能放入 `components/center/`、`components/sidebar/` 或 `components/dialogs/`。
- 对话框使用 `ElDialog` + `el-form` 结构，Props 定义 `visible`，Emits 定义 `update:visible` 与 `confirm`。

### Android（Kotlin）

- 采用 MVVM 模式，网络请求使用 Kotlin Coroutines + `suspend`。
- Retrofit 接口返回统一包装 `ApiResponse<T>`。
- Room 数据库支持离线浏览，WorkManager 负责后台数据同步。
- 图片加载使用 Coil，Markdown 渲染使用 Markwon。

---

## 测试策略

| 子项目 | 测试框架 | 测试位置 | 说明 |
|--------|----------|----------|------|
| Web | Vitest + @vue/test-utils + jsdom | `src/stores/__tests__/` | 对 Pinia Store 进行单元测试，覆盖状态初始化、异步 Mock、错误降级、移动端布局检测 |
| 后端 | CMake 自定义测试目标 | `calcite/test/` | 目前为基础框架（`test_main.cc`），可扩展为单元测试 |
| Android | JUnit + Espresso | `src/test/`、`src/androidTest/` | 目前为基础示例测试，可扩展 |

运行测试：
```bash
# Web
cd calcite_web/calcite-web && npm run test:run

# 后端
cd calcite_server/calcite/build && make calcite_test && ./test/calcite_test

# Android
cd calcite_android && ./gradlew test
```

---

## 部署与运行时依赖

启动完整系统前，需先部署以下基础设施：

1. **MariaDB**：端口 `3306`，创建数据库 `calcite`（字符集 `utf8mb4`）。
2. **Elasticsearch 8.12.2**：端口 `9200`，安装 IK 中文分词插件。
3. **MinIO**（Docker）：端口 `9000`（API）/ `9001`（Console），创建 bucket `notes-files` 并设为公开只读。
4. **后端服务**：编译后运行 `./calcite`，监听 `0.0.0.0:8888`。
5. **Web 前端**：`npm run build` 后，静态文件可由后端 `document_root` 直接托管，或独立部署。
6. **Android**：配置后端地址后编译安装 APK。

> 后端 `config.json` 中硬编码了数据库密码等敏感信息，生产环境需替换为环境变量或加密配置。

---

## 安全注意事项

1. **Token 存储**：
   - Web 端将 JWT 存储在 `localStorage`，存在 XSS 风险；禁止对用户输入使用 `v-html` 或 `innerHTML`。
   - Android 端使用 DataStore 存储 Token。
2. **401 处理**：前端拦截器在收到 401 时强制清除 token 并跳转登录页，防止残留无效凭证。
3. **CORS**：开发环境依赖 Vite 代理解决跨域；生产环境需确保后端 Drogon 正确配置 CORS。
4. **文件上传**：异步上传 + 轮询状态，避免前端长时间挂起请求。
5. **密码**：后端使用 `PasswordUtil` 对密码进行哈希存储，不保存明文。
6. **ES 权限**：搜索接口根据 `user_id` 过滤，确保用户只能检索自己的笔记（公开笔记除外）。

---

## 关键文件速查

| 路径 | 说明 |
|------|------|
| `calcite_server/calcite/config.json` | 后端服务配置（端口、DB、线程数） |
| `calcite_server/calcite/CMakeLists.txt` | 后端 CMake 构建配置 |
| `calcite_server/docs/schema.md` | 数据库设计（13 张表） |
| `calcite_server/docs/api.md` | REST API 完整文档 |
| `calcite_web/calcite-web/package.json` | Web 前端依赖与脚本 |
| `calcite_web/calcite-web/vite.config.js` | Vite 配置与代理 |
| `calcite_web/calcite-web/src/utils/request.js` | Axios 封装（拦截器、统一错误处理） |
| `calcite_web/calcite-web/src/stores/` | Pinia 状态管理 |
| `calcite_android/app/build.gradle.kts` | Android 模块构建配置 |
| `calcite_android/gradle/libs.versions.toml` | Android 依赖版本目录 |
| `calcite_android/app/src/main/java/com/calcite/notes/data/remote/ApiService.kt` | Android Retrofit API 接口定义 |

---

## 相关文档索引

- `calcite_server/docs/schema.md` — 数据库表结构设计
- `calcite_server/docs/api.md` — REST API 设计（前后端对接核心）
- `calcite_web/docs/dev_guide.md` — Web 端开发指南（组件、状态、主题）
- `calcite_web/docs/component_api.md` — Web 组件 API 文档
- `calcite_web/AGENTS.md` — Web 端专属 Agent 文档（更细粒度的前端规范）
- 各子模块 `docs/260*.md` — 按日期命名的历次开发/重构/热修记录

---

## 许可证

- 根仓库、Web、Android：[MIT](./LICENSE)
- 后端：[GPL-3.0](./calcite_server/LICENSE)
