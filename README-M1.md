# SurfSense - 苹果M芯片部署指南

本指南专门为苹果M芯片（Apple Silicon）用户提供 SurfSense 的部署方案。

## 🚀 快速开始

### 1. 系统要求

- **硬件**: 苹果M1/M2/M3芯片的Mac
- **操作系统**: macOS 11.0 (Big Sur) 或更高版本
- **Docker**: Docker Desktop for Mac (Apple Silicon版本)
- **内存**: 至少8GB RAM（推荐16GB）
- **存储**: 至少5GB可用空间

### 2. 安装Docker Desktop

1. 下载 [Docker Desktop for Mac (Apple Silicon)](https://desktop.docker.com/mac/main/arm64/Docker.dmg)
2. 安装并启动Docker Desktop
3. 确保Docker Desktop正在运行

### 3. 克隆项目

```bash
git clone <your-repo-url>
cd SurfSense
```

### 4. 配置环境变量

#### 后端配置 (backend/.env)

```bash
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
```

#### 前端配置 (SurfSense-Frontend/.env)

```bash
NEXT_PUBLIC_API_URL=http://localhost:8067
PORT=3087
```

### 5. 启动应用

```bash
# 方法1: 使用启动脚本（推荐）
chmod +x start-m1.sh
./start-m1.sh

# 方法2: 手动启动
docker compose -f docker-compose.m1.yml up --build
```

## 🔧 端口配置

为避免与其他服务冲突，本配置使用以下非常用端口：

- **前端**: 3087 (http://localhost:3087)
- **后端API**: 8067 (http://localhost:8067)
- **PostgreSQL**: 5467

## 📋 管理命令

### 查看服务状态
```bash
docker compose -f docker-compose.m1.yml ps
```

### 查看日志
```bash
# 查看所有服务日志
docker compose -f docker-compose.m1.yml logs -f

# 查看特定服务日志
docker compose -f docker-compose.m1.yml logs -f backend
docker compose -f docker-compose.m1.yml logs -f frontend
docker compose -f docker-compose.m1.yml logs -f db
```

### 停止服务
```bash
docker compose -f docker-compose.m1.yml down
```

### 重启服务
```bash
docker compose -f docker-compose.m1.yml restart
```

### 重新构建
```bash
docker compose -f docker-compose.m1.yml up --build
```

## 🛠️ 故障排除

### 1. 构建失败

如果遇到构建失败，尝试：

```bash
# 清理Docker缓存
docker system prune -f

# 重新构建
docker compose -f docker-compose.m1.yml build --no-cache
```

### 2. 端口冲突

如果端口被占用，可以修改 `docker-compose.m1.yml` 中的端口映射：

```yaml
ports:
  - "新端口:容器端口"
```

### 3. 权限问题

确保脚本有执行权限：

```bash
chmod +x start-m1.sh
```

### 4. 数据库连接问题

检查数据库是否正常启动：

```bash
docker compose -f docker-compose.m1.yml logs db
```

## 🔍 性能优化

### 1. Docker Desktop设置

- **内存**: 分配至少4GB给Docker Desktop
- **CPU**: 使用至少2个CPU核心
- **磁盘**: 确保有足够的磁盘空间

### 2. 本地开发模式

如果需要本地开发模式，可以：

```bash
# 只启动数据库
docker compose -f docker-compose.m1.yml up db -d

# 本地运行后端
cd backend
pip install -r requirements.txt
uvicorn server:app --host 0.0.0.0 --port 8067 --reload

# 本地运行前端
cd SurfSense-Frontend
npm install
npm run dev -- -p 3087
```

## 📊 监控和日志

### 查看容器资源使用情况
```bash
docker stats
```

### 进入容器调试
```bash
# 进入后端容器
docker compose -f docker-compose.m1.yml exec backend bash

# 进入数据库容器
docker compose -f docker-compose.m1.yml exec db psql -U surfsense_user -d surfsense_db
```

## 🔐 安全注意事项

1. **更改默认密码**: 修改 `docker-compose.m1.yml` 中的数据库密码
2. **API密钥**: 确保在 `.env` 文件中配置正确的API密钥
3. **防火墙**: 确保防火墙设置允许相应端口访问

## 🆘 获取帮助

如果遇到问题：

1. 检查Docker Desktop是否正常运行
2. 查看容器日志获取错误信息
3. 确保所有环境变量配置正确
4. 验证端口是否被其他服务占用

## 🎯 下一步

1. 访问 http://localhost:3087 开始使用SurfSense
2. 配置浏览器扩展（如果需要）
3. 根据需要调整配置参数

---

**注意**: 本配置专为苹果M芯片优化，如果您使用Intel Mac，请使用标准的 `docker-compose.yml` 配置。