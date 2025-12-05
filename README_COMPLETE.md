# Price Memory 【价格记忆】

🌍 **完整的电商价格监控解决方案**  
🛍️ **支持主流电商平台的价格抓取和监控**  
🔔 **智能告警系统，确保及时获得价格变化通知**  
⚡ **高可用架构，完善的错误处理和重试机制**  
🚀 **易于部署，支持开发和生产环境**  
🔧 **可扩展设计，模块化架构**

## ✨ 核心特性

### 🛍️ 多平台价格监控
- **Amazon**: 支持全球20+站点（美国、英国、德国、日本等）
- **淘宝/天猫**: 完整的商品信息和价格提取
- **京东**: 价格趋势分析和促销监控
- **拼多多**: 团购价格和优惠券监控
- **苏宁易购**: 家电数码专业监控
- **通用支持**: 任何包含价格信息的电商网站

### 🔔 智能告警系统
- **多种告警类型**: 价格下降、上涨、阈值、百分比变化、异常检测
- **多渠道推送**: 邮件、Webhook、短信、应用内通知
- **智能冷却机制**: 防止告警轰炸，可配置冷却时间
- **个性化规则**: 用户自定义告警条件和优先级

### ⚡ 高性能任务调度
- **智能调度算法**: 基于优先级和负载的任务分配
- **并发控制**: 可配置的并发数量和速率限制
- **失败重试**: 指数退避重试策略，自动错误恢复
- **负载均衡**: 自适应延迟调整，动态负载均衡

### 📊 深度数据分析
- **价格趋势**: 移动平均线、布林带、趋势线
- **统计分析**: 最高/最低价、波动率、分位数、标准差
- **异常检测**: Z-score、IQR方法、移动窗口检测
- **价格预测**: 线性回归、时间序列分析

### 👥 协作功能
- **收藏夹管理**: 商品分类、标签、分组
- **共享功能**: 用户间商品共享、权限控制
- **公共池**: 热门商品发现、社区推荐
- **权限系统**: 基于角色的访问控制（RBAC）

### 🛡️ 完善的安全机制
- **API认证**: API Key + JWT Token
- **数据加密**: 敏感信息加密存储
- **访问控制**: 细粒度的权限管理
- **审计日志**: 完整的操作日志记录

## 🏗️ 技术架构

### 前端技术栈
- **React 18**: 现代化用户界面
- **TypeScript**: 类型安全
- **Vite**: 快速构建工具
- **Refine**: 企业级前端框架
- **Ant Design**: 专业的UI组件库
- **ECharts**: 强大的数据可视化

### 后端技术栈
- **FastAPI**: 高性能Web框架
- **Python 3.12**: 现代化编程语言
- **Supabase**: 云数据库和认证服务
- **PostgreSQL**: 关系型数据库
- **Playwright**: 浏览器自动化
- **Redis**: 缓存和会话存储

### 基础设施
- **Docker**: 容器化部署
- **Nginx**: 反向代理和负载均衡
- **Prometheus**: 监控和指标收集
- **Grafana**: 可视化监控面板
- **Let's Encrypt**: SSL证书自动管理

## 🚀 快速开始

### 1. 环境准备

#### 系统要求
- Python 3.12+
- Node.js 18+
- Git
- Docker (推荐)

#### 推荐工具
- Python: `uv` (包管理器)
- Node.js: `pnpm` (包管理器)

### 2. 克隆项目

```bash
git clone https://github.com/hamr-hub/price-memory.git
cd price-memory
```

### 3. 快速启动（Docker）

```bash
# 开发环境
docker-compose -f spider/docker-compose.dev.yml up -d

# 生产环境
./spider/deploy.sh -e production

# 监控仪表板（推荐）
./scripts/start_monitor.sh
```

### 4. 手动设置

#### 后端设置

```bash
cd spider

# 安装依赖 (推荐使用uv)
uv sync
# 或使用pip
pip install -r requirements.txt

# 安装Playwright浏览器
uv run playwright install
# 或
playwright install

# 复制并配置环境文件
cp .env.development .env
# 编辑.env文件，配置Supabase连接信息
```

#### 前端设置

```bash
cd admin

# 安装依赖 (推荐使用pnpm)
pnpm install
# 或使用npm
npm install

# 创建环境配置
echo "VITE_API_URL=http://localhost:8000/api/v1" > .env.local
```

#### 数据库设置

```bash
cd spider
# 配置.env文件中的Supabase连接信息
python init_database.py
```

#### 启动服务

```bash
# 方式一：使用启动脚本（推荐）
python start_dev.py

# 方式二：手动启动
# 后端 (终端1)
cd spider
uv run uvicorn main:app --reload --port 8000

# 前端 (终端2)
cd admin
pnpm dev
```

### 5. 访问应用

- 前端管理界面: http://localhost:5173
- 后端API文档: http://localhost:8000/docs
- 后端健康检查: http://localhost:8000/health

## 📊 Admin Dashboard 监控

### 实时监控仪表板

Price Memory 提供了完整的实时监控仪表板，集成在Admin界面中。

#### 🖥️ 监控功能

- **系统资源监控**: CPU、内存、磁盘使用率实时监控
- **任务状态监控**: 任务执行状态、成功率、队列长度实时跟踪
- **价格监控**: 商品价格实时变化、趋势分析、异常检测
- **告警监控**: 告警触发、发送状态、成功率统计
- **WebSocket实时通信**: 基于WebSocket的实时数据推送

#### 📊 仪表板特性

- **多维度监控**: 5个主要监控标签页（概览、系统、任务、价格、告警）
- **实时数据**: WebSocket实时推送，无需手动刷新
- **交互式图表**: 折线图、柱状图、饼图、仪表盘
- **响应式设计**: 适配各种屏幕尺寸
- **数据导出**: 支持CSV、Excel格式导出

#### 🚀 快速访问

```bash
# 启动监控环境
./scripts/start_monitor.sh

# 访问监控仪表板
open http://localhost:5173/monitor

# 访问WebSocket测试工具
open http://localhost:5173/websocket-test
```

#### 📈 监控标签页说明

**概览标签页**
- 系统健康状态总览
- 关键指标仪表盘
- 任务成功率趋势
- 价格抓取统计
- 告警成功率统计

**系统监控标签页**
- CPU使用率监控（仪表盘 + 趋势图）
- 内存使用率监控
- 磁盘使用率监控
- 系统资源趋势分析

**任务监控标签页**
- 任务执行状态统计
- 任务成功率趋势
- 任务日志实时查看
- 任务队列长度监控

**价格监控标签页**
- 价格变化实时趋势
- 价格波动分析
- 价格准确性统计
- 商品监控统计

**告警监控标签页**
- 告警触发统计
- 告警发送成功率
- 告警历史记录
- 告警响应时间

#### 🔗 WebSocket集成

**连接信息**
- WebSocket地址: `ws://localhost:8001`
- 自动连接: 页面加载时自动连接
- 状态显示: 实时显示连接状态
- 自动重连: 连接断开时自动重连

**消息协议**
```json
// 订阅商品
{
  "type": "subscribe",
  "product_ids": [1, 2, 3]
}

// 价格更新推送
{
  "type": "price_update",
  "product_id": 123,
  "price": 99.99,
  "currency": "USD",
  "change": 2.5,
  "timestamp": "2024-01-01T12:00:00Z"
}

// 任务状态更新
{
  "type": "task_update",
  "task_id": 456,
  "status": "completed",
  "product_id": 123,
  "price": 99.99,
  "timestamp": "2024-01-01T12:00:00Z"
}
```

#### 📊 Prometheus + Grafana 监控栈

```bash
# 启动完整监控栈
./scripts/start_monitor.sh

# 访问监控面板
open http://localhost:9090  # Prometheus
open http://localhost:3001  # Grafana (admin/admin)
```

**监控指标**

- **API性能**: 响应时间、错误率、QPS
- **任务状态**: 成功率、队列长度、处理速度
- **系统资源**: CPU、内存、磁盘、网络
- **业务指标**: 价格抓取成功率、告警触发率

**告警规则**

- API响应时间 > 2秒
- 任务失败率 > 10%
- 数据库连接数 > 80%
- 磁盘使用率 > 90%

## 🔄 CI/CD

### 自动化部署

```bash
# 开发环境自动部署
./scripts/deploy-dev.sh

# 生产环境部署
./scripts/deploy-prod.sh

# 回滚到上一版本
./scripts/rollback.sh
```

### 流水线

1. **代码检查**: ESLint、Prettier、TypeScript检查
2. **单元测试**: pytest、Jest
3. **构建镜像**: Docker多阶段构建
4. **部署验证**: 健康检查、功能测试
5. **生产部署**: 蓝绿部署、流量切换

## 🛠️ 开发指南

### 添加新的电商平台

```python
# 1. 创建站点适配器
# spider/src/sites/new_site.py

from ..utils.base_site import BaseSiteAdapter

class NewSiteAdapter(BaseSiteAdapter):
    def detect_site_type(self, url: str) -> bool:
        return "newsite.com" in url.lower()
    
    def extract_price(self, page: Page) -> Tuple[float, str]:
        # 实现价格提取逻辑
        pass
    
    def extract_product_info(self, page: Page) -> Dict[str, Any]:
        # 实现商品信息提取逻辑
        pass

# 2. 注册到工厂
# spider/src/utils/site_factory.py
SITES = {
    'amazon': AmazonAdapter(),
    'taobao': TaobaoAdapter(),
    'newsite': NewSiteAdapter(),  # 新增
}
```

### 添加新的告警渠道

```python
# 1. 实现通知发送器
# spider/src/services/notification/sms_sender.py

class SMSSender(NotificationSender):
    async def send(self, event: AlertEvent) -> bool:
        # 实现短信发送逻辑
        pass

# 2. 注册到通知系统
# spider/src/services/intelligent_alert_system.py
self.notification_senders['sms'] = self._send_sms_notification
```

### 添加数据分析指标

```python
# 1. 在PriceHistoryService中添加新方法
def calculate_volatility_index(self, product_id: int, days: int = 30) -> float:
    """计算价格波动指数"""
    # 实现波动率计算逻辑
    pass

# 2. 添加API端点
@router.get("/products/{product_id}/volatility")
def get_price_volatility(product_id: int):
    # API实现
    pass
```

## 📚 API文档

完整的API文档请查看：
- **在线文档**: http://localhost:8000/docs
- **离线文档**: `spider/API_DOCUMENTATION.md`
- **Postman集合**: `docs/postman/PriceMemory_API.postman_collection.json`

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 代码规范

- **Python**: 使用 Black 格式化，flake8 检查
- **TypeScript**: 使用 Prettier 格式化，ESLint 检查
- **提交信息**: 遵循 Conventional Commits 规范

```bash
# 代码格式化
black spider/src/
prettier --write admin/src/

# 代码检查
flake8 spider/src/
eslint admin/src/

# 类型检查
uv run mypy spider/src/
npx tsc --noEmit
```

## 📖 文档

- **快速开始**: 本文档
- **API文档**: `spider/API_DOCUMENTATION.md`
- **架构设计**: `docs/architecture.md`
- **数据库设计**: `supabase/schema.sql`
- **部署指南**: `docs/deployment.md`

## 🐛 问题排查

### 常见问题

1. **Playwright安装失败**
   ```bash
   # 使用镜像源
   PLAYWRIGHT_DOWNLOAD_HOST=https://npmmirror.com/mirrors uvnpx playwright install
   ```

2. **数据库连接失败**
   ```bash
   # 检查环境变量
   echo $SUPABASE_URL
   # 测试连接
   python -c "import supabase; print('OK')"
   ```

3. **价格抓取失败**
   ```bash
   # 检查浏览器服务
   curl http://localhost:3000/health
   # 查看日志
   docker-compose logs playwright-browser
   ```

### 获取帮助

- **Issues**: https://github.com/hamr-hub/price-memory/issues
- **Discussions**: https://github.com/hamr-hub/price-memory/discussions
- **邮件**: support@pricememory.com

## 📄 许可证

MIT License

Copyright (c) 2024 Price Memory

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## 🙏 致谢

感谢所有为本项目做出贡献的开发者和测试用户！

## 📞 联系我们

- 项目地址: https://github.com/hamr-hub/price-memory
- 问题反馈: https://github.com/hamr-hub/price-memory/issues
- 邮箱: support@pricememory.com

---

**Price Memory** - 让价格监控更智能、更简单！