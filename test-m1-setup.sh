#!/bin/bash

# SurfSense M1配置测试脚本

echo "🔍 SurfSense M1配置检查"
echo "======================"

# 检查系统架构
echo "📱 检查系统架构..."
ARCH=$(uname -m)
echo "当前架构: $ARCH"

if [[ "$ARCH" == "arm64" ]]; then
    echo "✅ 检测到苹果M芯片"
else
    echo "⚠️  警告: 当前系统不是苹果M芯片 ($ARCH)"
    echo "   本配置专为ARM64优化，Intel Mac请使用标准配置"
fi

# 检查Docker
echo ""
echo "🐳 检查Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker已安装"
    DOCKER_VERSION=$(docker --version)
    echo "   版本: $DOCKER_VERSION"
    
    # 检查Docker是否运行
    if docker info &> /dev/null; then
        echo "✅ Docker服务正在运行"
    else
        echo "❌ Docker服务未运行，请启动Docker Desktop"
        exit 1
    fi
else
    echo "❌ Docker未安装"
    echo "   请安装Docker Desktop for Mac (Apple Silicon版本)"
    exit 1
fi

# 检查Docker Compose
echo ""
echo "🔧 检查Docker Compose..."
if command -v docker compose &> /dev/null; then
    echo "✅ Docker Compose可用"
    COMPOSE_VERSION=$(docker compose version)
    echo "   版本: $COMPOSE_VERSION"
else
    echo "❌ Docker Compose不可用"
    echo "   请确保使用最新版本的Docker Desktop"
    exit 1
fi

# 检查端口占用
echo ""
echo "🔌 检查端口占用..."
PORTS=(3087 8067 5467)
PORT_ISSUES=false

for port in "${PORTS[@]}"; do
    if lsof -i :$port &> /dev/null; then
        echo "⚠️  端口 $port 被占用"
        PORT_ISSUES=true
        echo "   占用进程: $(lsof -ti :$port | head -1 | xargs ps -o pid,comm -p)"
    else
        echo "✅ 端口 $port 可用"
    fi
done

if $PORT_ISSUES; then
    echo ""
    echo "🔧 解决方案:"
    echo "   1. 停止占用端口的服务"
    echo "   2. 或修改 docker-compose.m1.yml 中的端口映射"
fi

# 检查配置文件
echo ""
echo "📋 检查配置文件..."
CONFIG_FILES=(
    "docker-compose.m1.yml"
    "backend/Dockerfile.m1"
    "SurfSense-Frontend/Dockerfile.m1"
    "start-m1.sh"
)

for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
    fi
done

# 检查环境变量文件
echo ""
echo "🔐 检查环境变量..."
if [[ -f "backend/.env" ]]; then
    echo "✅ backend/.env 存在"
    
    # 检查关键环境变量
    if grep -q "OPENAI_API_KEY=your_openai_api_key_here" backend/.env; then
        echo "⚠️  请配置真实的OPENAI_API_KEY"
    else
        echo "✅ OPENAI_API_KEY 已配置"
    fi
else
    echo "⚠️  backend/.env 不存在，将在启动时创建"
fi

if [[ -f "SurfSense-Frontend/.env" ]]; then
    echo "✅ SurfSense-Frontend/.env 存在"
else
    echo "⚠️  SurfSense-Frontend/.env 不存在，将在启动时创建"
fi

# 总结
echo ""
echo "📊 配置检查总结"
echo "==============="

if [[ "$ARCH" == "arm64" ]] && command -v docker &> /dev/null && docker info &> /dev/null && command -v docker compose &> /dev/null; then
    echo "✅ 系统准备就绪！"
    echo ""
    echo "🚀 下一步:"
    echo "   1. 运行: ./start-m1.sh"
    echo "   2. 等待构建完成"
    echo "   3. 访问: http://localhost:3087"
    echo ""
    echo "💡 提示:"
    echo "   - 首次启动需要下载镜像，可能需要几分钟"
    echo "   - 确保网络连接良好"
    echo "   - 建议给Docker Desktop分配至少4GB内存"
else
    echo "❌ 存在配置问题，请解决上述问题后重试"
    exit 1
fi