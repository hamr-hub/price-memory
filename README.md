# Price Memory 【价格记忆】
- 价格记忆：记录商品价格变化，帮助用户做出更明智的购买决策。
- 灵活修改：抓取任何公开的信息维度，作为分析依据。

## 技术选型

### spider
- [playwright](https://playwright.dev/)

### data analysis

- [pandas](https://pandas.pydata.org/docs/)
- [numpy](https://numpy.org/doc/)
- [matplotlib](https://matplotlib.org/stable/contents.html)
- [seaborn](https://seaborn.pydata.org/index.html)

### data storage
- [postgresql](https://www.postgresql.org/)
- [supabase](https://supabase.com/)

### web framework
- [TypeScript](https://www.typescriptlang.org/docs/)
- [React](https://react.dev/)
- [Vite](https://vitejs.dev/)
- [Refine](https://refine.dev/docs/)

### deploy
- [docker](https://docs.docker.com/get-docker/)
- [kubernetes](https://kubernetes.io/docs/home/)


## 文档
- 文档索引：`.docs/Index.md`
- 技术路线：`.docs/00-技术路线.md`
- 开发指南：`.docs/03-开发指南.md`
- API 文档：`.docs/04-API文档.md`
- 推送与打包流程：`.docs/06-推送打包流程.md`

## 快速启动
```bash
# 后端（Windows PowerShell）
spider\.venv\Scripts\uvicorn.exe spider.main:app --host 127.0.0.1 --port 8000

# 前端
cd admin
npm install
npm run dev
```

前端默认访问 `http://localhost:5173`，后端 Base URL 为 `http://localhost:8000/api/v1`。

## 快速上手

### 前端（管理端）
- 进入目录并安装依赖：
  - `cd admin`
  - `npm install`
- 启动开发服务器：
  - `npm run dev`
- 可选：代码规范与类型检查：
  - `npm run lint`
  - `npm run type-check`
  - `npm run format`

前端默认连接 `http://localhost:8000/api/v1`，也可在 `admin/.env.local` 配置：
```
VITE_API_URL=http://localhost:8000/api/v1
```

### 后端（API）
- 进入目录并安装依赖（推荐使用 uv）：
  - `cd spider`
  - `uv sync`
- 安装 Playwright 浏览器：
  - `uv run playwright install`
- 启动开发服务：
  - `uv run uvicorn spider.main:app --reload --port 8000`

### 常见问题
- 前端顶部会显示 API 连接状态，若异常请确认后端是否启动，以及 `VITE_API_URL` 是否配置正确。
- Windows 环境建议在 PowerShell 中运行命令。

### 一键推送
- Windows：`pwsh -File scripts/oneclick-push.ps1 -DryRun`
- Linux/macOS：`DRYRUN=1 ./scripts/oneclick-push.sh`

## 架构
