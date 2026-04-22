# Intelligent note-taking system based on both Web and Android platforms
# Calcite — 基于 Web 与 Android 双端的智能笔记系统
<!-- 毕业设计-哈尔滨理工大学-2204020121 -->

跨平台智能笔记管理系统，支持 Web 前端、Android 客户端与 C++ 后端服务。

---

## 项目结构

本项目由三个子模块组成：

| 子模块 | 路径 | 技术栈 | 说明 |
|--------|------|--------|------|
| 后端服务 | `calcite_server/` | Drogon (C++17/20) + MariaDB + Elasticsearch + MinIO | RESTful API 服务端 |
| Web 前端 | `calcite_web/` | Vue 3 + Vite + Pinia + Element Plus | 三栏式笔记管理 SPA |
| Android | `calcite_android/` | Kotlin + Jetpack (Room/Navigation/WorkManager) | 移动端笔记 App |

---

## 快速开始

### 后端

```bash
cd calcite_server/calcite
mkdir -p build && cd build
cmake .. && make -j$(nproc)
./calcite
```

### Web 前端

```bash
cd calcite_web/calcite-web
npm install
npm run dev
```

### Android

```bash
cd calcite_android
./gradlew installDebug
```

---

## 子仓库

- [calcite_server](https://github.com/NANNO35578/calcite_server) — 后端服务
- [calcite_web](https://github.com/NANNO35578/calcite_web) — Web 前端
- [calcite_android](https://github.com/NANNO35578/calcite_android) — Android 客户端
