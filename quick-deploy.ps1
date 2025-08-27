# KattSafe PDF QA - Windows PowerShell 快速部署脚本

Write-Host "🚀 KattSafe PDF QA - 快速部署到Vercel" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查是否在正确的目录
if (-not (Test-Path "pdf-qa-frontend")) {
    Write-Host "❌ 错误: 请在KattSafe项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 第1步: 检查依赖
Write-Host "`n📦 检查依赖..." -ForegroundColor Green

try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Gray
} catch {
    Write-Host "❌ Node.js 未安装，请先安装 Node.js" -ForegroundColor Red
    exit 1
}

try {
    $npmVersion = npm --version  
    Write-Host "✅ npm: $npmVersion" -ForegroundColor Gray
} catch {
    Write-Host "❌ npm 未安装" -ForegroundColor Red
    exit 1
}

# 第2步: 安装前端依赖
Write-Host "`n📥 安装前端依赖..." -ForegroundColor Green
Set-Location "pdf-qa-frontend"

if (-not (Test-Path "node_modules")) {
    Write-Host "正在安装依赖..." -ForegroundColor Yellow
    npm install
    Write-Host "✅ 依赖安装完成" -ForegroundColor Gray
} else {
    Write-Host "✅ 依赖已存在" -ForegroundColor Gray
}

# 第3步: 检查环境变量  
Write-Host "`n🔧 检查环境变量..." -ForegroundColor Green

if (-not (Test-Path ".env")) {
    Write-Host "⚠️  创建 .env 文件..." -ForegroundColor Yellow
    @"
# 开发环境
REACT_APP_API_URL=http://localhost:8000

# 生产环境 - 部署后端后请更新此URL
# REACT_APP_API_URL=https://your-backend.railway.app
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "✅ .env 文件已创建" -ForegroundColor Gray
} else {
    Write-Host "✅ .env 文件已存在" -ForegroundColor Gray
}

# 第4步: 检查Vercel CLI
Write-Host "`n🌐 检查Vercel CLI..." -ForegroundColor Green

try {
    $vercelVersion = vercel --version
    Write-Host "✅ Vercel CLI: $vercelVersion" -ForegroundColor Gray
} catch {
    Write-Host "📥 安装Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
    Write-Host "✅ Vercel CLI 安装完成" -ForegroundColor Gray
}

# 回到根目录
Set-Location ".."

# 第5步: 显示部署指令
Write-Host "`n🎯 部署步骤:" -ForegroundColor Green
Write-Host "1. 登录Vercel: vercel login" -ForegroundColor White
Write-Host "2. 进入前端目录: cd pdf-qa-frontend" -ForegroundColor White  
Write-Host "3. 部署项目: vercel --prod" -ForegroundColor White
Write-Host "4. 配置环境变量: 在Vercel控制台设置 REACT_APP_API_URL" -ForegroundColor White

Write-Host "`n📋 后端部署:" -ForegroundColor Green
Write-Host "1. 访问 https://railway.app" -ForegroundColor White
Write-Host "2. 连接GitHub仓库" -ForegroundColor White
Write-Host "3. 选择 backend/ 目录" -ForegroundColor White
Write-Host "4. 配置环境变量" -ForegroundColor White

Write-Host "`n✅ 准备完成！现在可以开始部署了" -ForegroundColor Green

# 询问是否立即开始部署
$choice = Read-Host "`n是否现在登录Vercel并开始部署? (y/n)"
if ($choice -eq "y" -or $choice -eq "Y") {
    Write-Host "`n🚀 开始Vercel部署..." -ForegroundColor Cyan
    Set-Location "pdf-qa-frontend"
    vercel login
    
    $deployChoice = Read-Host "`n继续部署到生产环境? (y/n)"
    if ($deployChoice -eq "y" -or $deployChoice -eq "Y") {
        vercel --prod
    }
}

Write-Host "`n🎉 脚本执行完成！" -ForegroundColor Green

# 显示有用的链接
Write-Host "`n🔗 有用链接:" -ForegroundColor Cyan
Write-Host "   Vercel控制台: https://vercel.com/dashboard" -ForegroundColor Blue
Write-Host "   Railway控制台: https://railway.app/dashboard" -ForegroundColor Blue
Write-Host "   部署指南: deployment-checklist.md" -ForegroundColor Blue
