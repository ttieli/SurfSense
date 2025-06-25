#!/bin/bash

# SurfSense - 苹果M芯片启动脚本
# 使用非常用端口：前端3087, 后端8067, 数据库5467

echo "🚀 启动 SurfSense - 苹果M芯片版本"
echo "================================"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装。请先安装 Docker Desktop for Mac (Apple Silicon)"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker compose &> /dev/null; then
    echo "错误: Docker Compose 未安装。请确保使用最新版本的 Docker Desktop"
    exit 1
fi

# 检查是否为苹果M芯片
if [[ $(uname -m) != "arm64" ]]; then
    echo "警告: 此脚本专为苹果M芯片设计"
    echo "当前架构: $(uname -m)"
    echo "如果您使用的是Intel Mac，请使用标准的docker-compose.yml"
fi

# 创建必要的环境变量文件
echo "🔧 检查环境配置..."

# 后端环境变量
if [ ! -f "backend/.env" ]; then
    echo "创建后端环境变量文件..."
    cat > backend/.env << EOL
# 数据库配置
DATABASE_URL=postgresql://surfsense_user:surfsense_m1_password_2024@db:5432/surfsense_db

# API配置
OPENAI_API_KEY=your_openai_api_key_here
SMART_LLM=openai:gpt-4
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALGORITHM=HS256
API_SECRET_KEY=your_api_secret_key_here
SECRET_KEY=your_secret_key_here
UNSTRUCTURED_API_KEY=your_unstructured_api_key_here
EOL
fi

# 前端环境变量
if [ ! -f "SurfSense-Frontend/.env" ]; then
    echo "创建前端环境变量文件..."
    cat > SurfSense-Frontend/.env << EOL
NEXT_PUBLIC_API_URL=http://localhost:8067
PORT=3087
EOL
fi

# 停止现有容器
echo "🛑 停止现有容器..."
docker compose -f docker-compose.m1.yml down

# 清理构建缓存（可选）
read -p "是否清理Docker构建缓存? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 清理构建缓存..."
    docker system prune -f
fi

# 构建并启动容器
echo "🔨 构建并启动容器..."
docker compose -f docker-compose.m1.yml up --build -d

# 检查容器状态
echo "📊 检查容器状态..."
sleep 5
docker compose -f docker-compose.m1.yml ps

echo ""
echo "✅ SurfSense 已启动！"
echo "================================"
echo "🌐 前端地址: http://localhost:3087"
echo "🔗 后端API: http://localhost:8067"
echo "🗄️ 数据库端口: 5467"
echo ""
echo "📝 注意事项:"
echo "- 请确保在 backend/.env 中配置正确的API密钥"
echo "- 首次启动可能需要几分钟来下载和构建镜像"
echo "- 如果遇到权限问题，请确保 start-m1.sh 有执行权限"
echo ""
echo "🛠️ 管理命令:"
echo "- 查看日志: docker compose -f docker-compose.m1.yml logs -f"
echo "- 停止服务: docker compose -f docker-compose.m1.yml down"
echo "- 重启服务: docker compose -f docker-compose.m1.yml restart"
echo ""
echo "🎉 享受使用 SurfSense！"