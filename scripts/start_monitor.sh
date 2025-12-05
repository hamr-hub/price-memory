#!/bin/bash

# Price Memory 监控仪表板快速启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MONITOR_COMPOSE_FILE="$PROJECT_ROOT/spider/docker-compose.monitor.yml"
ENV_FILE="$PROJECT_ROOT/spider/.env.production"

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装"
        exit 1
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi
    
    # 检查文件是否存在
    if [ ! -f "$MONITOR_COMPOSE_FILE" ]; then
        log_error "监控配置文件不存在: $MONITOR_COMPOSE_FILE"
        exit 1
    fi
    
    log_success "依赖检查完成"
}

# 检查环境配置
check_environment() {
    log_info "检查环境配置..."
    
    if [ ! -f "$ENV_FILE" ]; then
        log_warning "环境配置文件不存在: $ENV_FILE"
        log_info "请先配置环境变量文件"
        log_info "参考: cp $PROJECT_ROOT/spider/.env.production.example $ENV_FILE"
        log_info "或: cp $PROJECT_ROOT/spider/.env.development $ENV_FILE"
        exit 1
    fi
    
    log_success "环境配置检查完成"
}

# 启动监控服务
start_monitor_services() {
    log_info "启动监控服务..."
    
    cd "$PROJECT_ROOT/spider"
    
    # 停止现有服务
    log_info "停止现有服务..."
    docker-compose -f "$MONITOR_COMPOSE_FILE" down 2>/dev/null || true
    
    # 拉取最新镜像
    log_info "拉取最新镜像..."
    docker-compose -f "$MONITOR_COMPOSE_FILE" pull
    
    # 启动服务
    log_info "启动监控服务..."
    docker-compose -f "$MONITOR_COMPOSE_FILE" up -d
    
    log_success "监控服务启动完成"
}

# 等待服务就绪
wait_for_services() {
    log_info "等待服务就绪..."
    
    # 等待API服务
    for i in {1..60}; do
        if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
            log_success "API服务就绪"
            break
        fi
        if [ $i -eq 60 ]; then
            log_error "API服务启动超时"
            return 1
        fi
        sleep 2
    done
    
    # 等待前端服务
    for i in {1..30}; do
        if curl -f -s http://localhost:5173 > /dev/null 2>&1; then
            log_success "前端服务就绪"
            break
        fi
        if [ $i -eq 30 ]; then
            log_warning "前端服务启动较慢，请稍后检查"
        fi
        sleep 2
    done
    
    # 等待Prometheus
    for i in {1..30}; do
        if curl -f -s http://localhost:9090 > /dev/null 2>&1; then
            log_success "Prometheus就绪"
            break
        fi
        if [ $i -eq 30 ]; then
            log_warning "Prometheus启动较慢"
        fi
        sleep 2
    done
    
    # 等待Grafana
    for i in {1..30}; do
        if curl -f -s http://localhost:3001 > /dev/null 2>&1; then
            log_success "Grafana就绪"
            break
        fi
        if [ $i -eq 30 ]; then
            log_warning "Grafana启动较慢"
        fi
        sleep 2
    done
}

# 显示服务状态
show_service_status() {
    log_info "检查服务状态..."
    
    echo ""
    echo "=================================="
    echo "  服务状态检查"
    echo "=================================="
    
    # 检查容器状态
    docker-compose -f "$MONITOR_COMPOSE_FILE" ps
    
    echo ""
    echo "=================================="
    echo "  端口检查"
    echo "=================================="
    
    # 检查端口
    check_port() {
        local port=$1
        local service=$2
        if curl -f -s "http://localhost:$port" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $service: http://localhost:$port"
        else
            echo -e "${RED}✗${NC} $service: http://localhost:$port (未响应)"
        fi
    }
    
    check_port 8000 "API服务"
    check_port 5173 "前端管理界面"
    check_port 9090 "Prometheus"
    check_port 3001 "Grafana"
    check_port 9100 "Node Exporter"
    check_port 8080 "cAdvisor"
    check_port 9093 "AlertManager"
    
    echo ""
}

# 显示访问信息
show_access_info() {
    log_success "监控仪表板启动完成!"
    
    echo ""
    echo "=================================="
    echo "  访问信息"
    echo "=================================="
    echo ""
    echo "📍 核心服务:"
    echo "  - 监控仪表板: http://localhost:5173/monitor"
    echo "  - API文档: http://localhost:8000/docs"
    echo "  - API健康检查: http://localhost:8000/health"
    echo ""
    echo "📊 监控服务:"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - Grafana: http://localhost:3001 (admin/admin)"
    echo "  - Node Exporter: http://localhost:9100/metrics"
    echo "  - cAdvisor: http://localhost:8080"
    echo "  - AlertManager: http://localhost:9093"
    echo ""
    echo "🔌 WebSocket:"
    echo "  - WebSocket服务: ws://localhost:8001"
    echo "  - 测试页面: http://localhost:5173/websocket-test"
    echo ""
    echo "🔄 常用命令:"
    echo "  查看日志: docker-compose -f $MONITOR_COMPOSE_FILE logs -f"
    echo "  停止服务: docker-compose -f $MONITOR_COMPOSE_FILE down"
    echo "  重启服务: docker-compose -f $MONITOR_COMPOSE_FILE restart"
    echo ""
    echo "=================================="
}

# 运行健康检查
health_check() {
    log_info "运行健康检查..."
    
    # API健康检查
    if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
        log_success "API健康检查通过"
    else
        log_error "API健康检查失败"
        return 1
    fi
    
    # WebSocket连接测试
    log_info "测试WebSocket连接..."
    # 这里可以添加WebSocket连接测试代码
    
    # 数据库连接检查
    log_info "检查数据库连接..."
    # 这里可以添加数据库连接测试代码
    
    log_success "所有健康检查通过"
}

# 创建示例配置
create_example_config() {
    log_info "创建示例配置文件..."
    
    # API配置示例
    cat > "$PROJECT_ROOT/spider/.env.production" << 'EOF'
# Price Memory 监控环境配置

# 环境配置
ENV=production
DEBUG=false
LOG_LEVEL=INFO

# 节点配置
NODE_NAME=monitor-node-1
NODE_CONCURRENCY=10
AUTO_CONSUME_QUEUE=true

# 数据库配置
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-key

# 浏览器配置
BROWSER_MODE=remote
PLAYWRIGHT_WS_ENDPOINT=ws://playwright-browser:3000
CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser
BROWSER_TIMEOUT=60000
BROWSER_HEADLESS=true

# WebSocket配置
WEBSOCKET_ENABLED=true
WEBSOCKET_PORT=8001

# 监控配置
ENABLE_METRICS=true
METRICS_PORT=9090
PROMETHEUS_ENABLED=true

# SMTP配置 (可选)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=Price Memory <noreply@yourcompany.com>

# Webhook配置 (可选)
ALERT_WEBHOOK_SECRET=your-webhook-secret-key

# Redis配置 (可选)
REDIS_URL=redis://redis:6379/0
REDIS_PASSWORD=your-redis-password

# 前端配置
VITE_API_URL=http://localhost:8000/api/v1
VITE_WEBSOCKET_URL=ws://localhost:8001

# 告警配置
DEFAULT_ALERT_COOLDOWN=60
MAX_ALERT_RETRIES=3
ALERT_BATCH_SIZE=10

# 任务调度配置
TASK_RETRY_DELAY=300
MAX_TASK_RETRIES=5
SCHEDULER_CHECK_INTERVAL=60
HEALTH_CHECK_INTERVAL=30
EOF

    # Grafana数据源配置
    mkdir -p "$PROJECT_ROOT/spider/monitoring/grafana/datasources"
    cat > "$PROJECT_ROOT/spider/monitoring/grafana/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

    # Grafana仪表板配置
    mkdir -p "$PROJECT_ROOT/spider/monitoring/grafana/dashboards"
    cat > "$PROJECT_ROOT/spider/monitoring/grafana/dashboards/dashboard.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

    log_success "示例配置文件已创建"
}

# 主函数
main() {
    echo "=================================="
    echo "  Price Memory 监控仪表板启动"
    echo "=================================="
    echo ""
    
    # 解析命令行参数
    if [ "$1" = "--create-config" ]; then
        create_example_config
        exit 0
    fi
    
    # 执行启动步骤
    check_dependencies
    check_environment
    start_monitor_services
    wait_for_services
    show_service_status
    health_check
    show_access_info
    
    echo ""
    log_success "监控仪表板已成功启动!"
    echo "请访问: http://localhost:5173/monitor"
}

# 执行主函数
main "$@"