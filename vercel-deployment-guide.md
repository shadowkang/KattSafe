# Vercel 部署指南 - PDF QA 项目

## 🚀 项目部署概述

您的项目包含两个部分：
1. **React 前端** - 可以部署到 Vercel
2. **Python FastAPI 后端** - 需要部署到支持 Python 的平台

## 📋 部署步骤

### 1. 后端部署（推荐平台）

#### 选项A: Railway (推荐)
- 免费额度充足
- 支持 Python
- 简单配置

#### 选项B: Render
- 免费层可用
- 自动 HTTPS
- 容器化部署

#### 选项C: Vercel Serverless Functions
- 与前端在同一平台
- 需要改造为无服务器函数

### 2. 前端部署到 Vercel

## 🔧 配置修改

### 环境变量配置
- 开发环境：`REACT_APP_API_URL=http://localhost:8000`
- 生产环境：`REACT_APP_API_URL=https://your-backend.railway.app`

### PDF 文件处理
- 上传到云存储（如 AWS S3, Cloudinary）
- 或打包到后端项目中

## 📁 文件结构调整
```
KattSafe/
├── frontend/          # React 应用
├── backend/           # FastAPI 应用  
├── pdfs/             # PDF 文件
├── vercel.json       # Vercel 配置
└── requirements.txt  # Python 依赖
```

## ⚡ 快速部署命令
```bash
# 1. 安装 Vercel CLI
npm i -g vercel

# 2. 登录 Vercel
vercel login

# 3. 部署前端
cd pdf-qa-frontend
vercel --prod
```

## 🔗 完整部署后的架构
- 前端：https://your-app.vercel.app
- 后端：https://your-api.railway.app
- PDF 存储：云存储服务
