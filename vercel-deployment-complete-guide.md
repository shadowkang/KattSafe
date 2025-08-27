# 🚀 KattSafe PDF QA 系统 - Vercel 部署指南

## 📋 项目概述

您的项目包含：
- **前端**: React 应用（聊天界面）
- **后端**: Python FastAPI（PDF问答API）
- **PDF文件**: 本地PDF文档

## 🔧 部署架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Vercel        │    │   Railway       │    │   Cloud Storage │
│   (Frontend)    │───▶│   (Backend)     │───▶│   (PDF Files)   │
│   React App     │    │   FastAPI       │    │   S3/Cloudinary │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 部署步骤

### 第1步：准备文件结构

```bash
KattSafe/
├── frontend/              # ← 重命名 pdf-qa-frontend
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── .env
├── backend/               # ← 新创建
│   ├── main.py
│   ├── pdf_qa.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env
├── pdfs/                  # ← PDF文件
│   ├── harness-gear-operation-manual.pdf
│   └── 2920-sp391-sp392-skylight-mesh-fixing-details-with-clip.pdf
└── vercel.json           # ← Vercel配置
```

### 第2步：复制PDF文件到后端

```powershell
# 创建后端PDF目录
mkdir "d:\KattSafe\backend\pdfs"

# 复制PDF文件
copy "d:\KattSafe\harness-gear-operation-manual.pdf" "d:\KattSafe\backend\pdfs\"
copy "d:\KattSafe\2920-sp391-sp392-skylight-mesh-fixing-details-with-clip.pdf" "d:\KattSafe\backend\pdfs\"
```

### 第3步：后端部署到 Railway

#### 3.1 注册 Railway
1. 访问 [railway.app](https://railway.app)
2. 使用 GitHub 账户登录
3. 连接您的 GitHub 仓库

#### 3.2 配置环境变量
在 Railway 项目设置中添加：
```
AZURE_OPENAI_API_KEY=您的Azure OpenAI密钥
AZURE_OPENAI_ENDPOINT=https://azureaitestenv.cognitiveservices.azure.com/
AZURE_OPENAI_DEPLOYMENT=gpt-4
CORS_ORIGINS=https://your-frontend.vercel.app
```

#### 3.3 部署命令
```bash
# 进入后端目录
cd backend

# 初始化 git（如果需要）
git init
git add .
git commit -m "Initial backend deployment"

# 推送到 Railway
# 或者直接在 Railway 控制台连接 GitHub 仓库
```

### 第4步：前端部署到 Vercel

#### 4.1 安装 Vercel CLI
```powershell
npm install -g vercel
```

#### 4.2 登录 Vercel
```powershell
vercel login
```

#### 4.3 配置环境变量
```powershell
# 进入前端目录
cd pdf-qa-frontend

# 编辑 .env 文件
REACT_APP_API_URL=https://your-backend.railway.app
```

#### 4.4 部署前端
```powershell
# 构建并部署
vercel --prod

# 或者连接 GitHub 进行自动部署
vercel --prod --confirm
```

### 第5步：配置域名和CORS

1. **获取前端URL**: `https://your-app.vercel.app`
2. **获取后端URL**: `https://your-backend.railway.app`  
3. **更新CORS设置**: 在Railway环境变量中更新 `CORS_ORIGINS`

## 🔗 替代部署方案

### 方案A: 全部部署到 Vercel（推荐）

```javascript
// vercel.json - 全栈配置
{
  "functions": {
    "api/**.py": {
      "runtime": "python3.9"
    }
  },
  "routes": [
    { "src": "/api/(.*)", "dest": "/api/$1" },
    { "src": "/(.*)", "dest": "/frontend/$1" }
  ]
}
```

### 方案B: Heroku + Vercel

```bash
# Heroku 部署后端
heroku create your-pdf-qa-backend
git push heroku main

# Vercel 部署前端
vercel --prod
```

### 方案C: DigitalOcean App Platform

- 支持 Docker 容器
- 自动扩缩容
- 内置数据库支持

## 📝 环境变量配置

### 前端 (.env)
```
REACT_APP_API_URL=https://your-backend.railway.app
REACT_APP_ENVIRONMENT=production
```

### 后端 (.env)
```
AZURE_OPENAI_API_KEY=your_key_here
AZURE_OPENAI_ENDPOINT=your_endpoint_here
AZURE_OPENAI_DEPLOYMENT=gpt-4
CORS_ORIGINS=https://your-frontend.vercel.app,http://localhost:3000
PORT=8000
PDF_BASE_PATH=/app/pdfs
```

## 🧪 测试部署

### 本地测试
```powershell
# 测试后端
cd backend
python main.py

# 测试前端
cd ../pdf-qa-frontend
npm start
```

### 生产测试
```bash
# 测试 API 健康检查
curl https://your-backend.railway.app/health

# 测试前端
curl https://your-frontend.vercel.app
```

## 🚨 常见问题解决

### 1. CORS 错误
```javascript
// 确保后端 CORS 配置正确
CORS_ORIGINS=https://your-frontend.vercel.app
```

### 2. API 超时
```python
# 增加超时设置
timeout=120  # 秒
```

### 3. PDF 文件未找到
```bash
# 确保 PDF 文件已复制到后端
ls backend/pdfs/
```

### 4. 环境变量问题
```bash
# 检查环境变量是否正确设置
echo $REACT_APP_API_URL
```

## 📊 成本估算

| 服务 | 免费额度 | 付费起价 |
|------|----------|----------|
| Vercel | 100GB带宽/月 | $20/月 |
| Railway | 500小时/月 | $5/月 |
| Azure OpenAI | 按使用量计费 | ~$0.002/1K tokens |

## 🎉 部署完成后

1. **前端地址**: `https://your-app.vercel.app`
2. **API文档**: `https://your-backend.railway.app/docs`
3. **健康检查**: `https://your-backend.railway.app/health`

## 🔄 自动部署设置

### GitHub Actions (可选)
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [ main ]
jobs:
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
```

部署成功后，您的PDF问答系统就可以在云端正常运行了！ 🚀
