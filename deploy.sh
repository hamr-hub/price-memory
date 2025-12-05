#!/bin/bash

# Price Memory 项目部署脚本
# 用于快速部署到生产环境

set -e

echo "🚀 Price Memory 项目部署脚本"
echo "================================"

# 检查必要的工具
check_requirements() {
    echo "📋 检查部署要求..."
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    echo "✅ 部署要求检查通过"
}

# 创建生产环境配置
setup_production_env() {
    echo "⚙️  设置生产环境配置..."
    
    # 创建生产环境配置目录
    mkdir -p deploy/production
    
    # 生成生产环境的 docker-compose.yml
    cat > deploy/production/docker-compose.yml << 'EOF'
version: '3.8'

services:
  price-memory-api:
    build:
      context: ../../spider
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_KEY=${SUPABASE_KEY}
      - PLAYWRIGHT_WS_ENDPOINT=${PLAYWRIGHT_WS_ENDPOINT}
      - NODE_CONCURRENCY=${NODE_CONCURRENCY:-2}
      - AUTO_CONSUME_QUEUE=true
      - DEBUG=false
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  price-memory-admin:
    build:
      context: ../../admin
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://localhost:8000/api/v1
    restart: unless-stopped
    depends_on:
      - price-memory-api

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - price-memory-api
      - price-memory-admin
    restart: unless-stopped

volumes:
  logs:
EOF

    # 生成 Nginx 配置
    cat > deploy/production/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api {
        server price-memory-api:8000;
    }
    
    upstream admin {
        server price-memory-admin:3000;
    }
    
    server {
        listen 80;
        server_name _;
        
        # API 代理
        location /api/ {
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # 管理界面
        location / {
            proxy_pass http://admin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

    # 创建环境变量模板
    cat > deploy/production/.env.example << 'EOF'
# Supabase 配置
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_anon_key_here

# Playwright 配置
PLAYWRIGHT_WS_ENDPOINT=ws://your-playwright-server:20001/

# 节点配置
NODE_CONCURRENCY=2

# SMTP 配置（可选）
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
SMTP_FROM=your_email@gmail.com

# Webhook 配置（可选）
ALERT_WEBHOOK_SECRET=your_webhook_secret
EOF

    echo "✅ 生产环境配置创建完成"
}

# 构建 Docker 镜像
build_images() {
    echo "🔨 构建 Docker 镜像..."
    
    # 构建后端镜像
    echo "构建后端镜像..."
    cat > spider/Dockerfile << 'EOF'
FROM python:3.12-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY pyproject.toml uv.lock* ./

# 安装 uv 和 Python 依赖
RUN pip install uv
RUN uv sync --frozen

# 安装 Playwright 浏览器
RUN uv run playwright install --with-deps chromium

# 复制应用代码
COPY . .

# 创建日志目录
RUN mkdir -p logs

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

    # 构建前端镜像
    echo "构建前端镜像..."
    cat > admin/Dockerfile << 'EOF'
FROM node:18-alpine as builder

WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN npm ci

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 生产镜像
FROM nginx:alpine

# 复制构建结果
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
EOF

    # 创建前端 Nginx 配置
    cat > admin/nginx.conf << 'EOF'
server {
    listen 3000;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://price-memory-api:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

    echo "✅ Docker 镜像配置创建完成"
}

# 部署应用
deploy_application() {
    echo "🚀 部署应用..."
    
    cd deploy/production
    
    # 检查环境变量文件
    if [ ! -f .env ]; then
        echo "❌ 请先创建 .env 文件并配置必要的环境变量"
        echo "可以参考 .env.example 文件"
        exit 1
    fi
    
    # 启动服务
    docker-compose up -d --build
    
    echo "✅ 应用部署完成"
    echo ""
    echo "📊 服务状态:"
    docker-compose ps
    echo ""
    echo "🌐 访问地址:"
    echo "   管理界面: http://localhost"
    echo "   API 文档: http://localhost/api/docs"
    echo ""
    echo "📝 查看日志:"
    echo "   docker-compose logs -f"
}

# 主函数
main() {
    case "${1:-deploy}" in
        "check")
            check_requirements
            ;;
        "setup")
            check_requirements
            setup_production_env
            build_images
            echo "✅ 部署环境设置完成"
            echo "请编辑 deploy/production/.env 文件，然后运行 ./deploy.sh deploy"
            ;;
        "deploy")
            check_requirements
            if [ ! -d "deploy/production" ]; then
                echo "⚠️  部署配置不存在，正在创建..."
                setup_production_env
                build_images
            fi
            deploy_application
            ;;
        "stop")
            echo "🛑 停止服务..."
            cd deploy/production
            docker-compose down
            echo "✅ 服务已停止"
            ;;
        "logs")
            echo "📝 查看日志..."
            cd deploy/production
            docker-compose logs -f
            ;;
        "status")
            echo "📊 服务状态..."
            cd deploy/production
            docker-compose ps
            ;;
        *)
            echo "用法: $0 {check|setup|deploy|stop|logs|status}"
            echo ""
            echo "命令说明:"
            echo "  check  - 检查部署要求"
            echo "  setup  - 设置部署环境"
            echo "  deploy - 部署应用"
            echo "  stop   - 停止服务"
            echo "  logs   - 查看日志"
            echo "  status - 查看服务状态"
            exit 1
            ;;
    esac
}

main "$@"