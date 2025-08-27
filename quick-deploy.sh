#!/bin/bash

# KattSafe PDF QA - 快速部署脚本
echo "🚀 KattSafe PDF QA - 快速部署到Vercel"
echo "========================================"

# 检查是否在正确的目录
if [ ! -d "pdf-qa-frontend" ]; then
    echo "❌ 错误: 请在KattSafe项目根目录运行此脚本"
    exit 1
fi

# 第1步: 检查依赖
echo "📦 检查依赖..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm 未安装"
    exit 1
fi

echo "✅ Node.js 和 npm 已安装"

# 第2步: 安装前端依赖
echo "📥 安装前端依赖..."
cd pdf-qa-frontend

if [ ! -d "node_modules" ]; then
    npm install
    echo "✅ 依赖安装完成"
else
    echo "✅ 依赖已存在"
fi

# 第3步: 检查环境变量
echo "🔧 检查环境变量..."

if [ ! -f ".env" ]; then
    echo "⚠️  创建 .env 文件..."
    cat > .env << EOF
# 开发环境
REACT_APP_API_URL=http://localhost:8000

# 生产环境 - 部署后端后请更新此URL
# REACT_APP_API_URL=https://your-backend.railway.app
EOF
    echo "✅ .env 文件已创建"
else
    echo "✅ .env 文件已存在"
fi

# 第4步: 安装Vercel CLI
echo "🌐 检查Vercel CLI..."

if ! command -v vercel &> /dev/null; then
    echo "📥 安装Vercel CLI..."
    npm install -g vercel
    echo "✅ Vercel CLI 安装完成"
else
    echo "✅ Vercel CLI 已安装"
fi

# 第5步: 部署指令
echo ""
echo "🎯 部署步骤:"
echo "1. 登录Vercel: vercel login"
echo "2. 部署项目: vercel --prod"
echo "3. 配置环境变量: 在Vercel控制台设置 REACT_APP_API_URL"
echo ""
echo "📋 后端部署:"
echo "1. 访问 https://railway.app"  
echo "2. 连接GitHub仓库"
echo "3. 选择 backend/ 目录"
echo "4. 配置环境变量"
echo ""
echo "✅ 准备完成！现在可以开始部署了"

# 询问是否立即开始部署
read -p "是否现在登录Vercel并开始部署? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 开始Vercel部署..."
    vercel login
    vercel --prod
fi

echo "🎉 脚本执行完成！"
