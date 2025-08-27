# 🚀 Vercel 部署自动化脚本

Write-Host "="*70 -ForegroundColor Cyan
Write-Host "    KattSafe PDF QA 系统 - Vercel 部署助手" -ForegroundColor Yellow
Write-Host "="*70 -ForegroundColor Cyan

$baseDir = "d:\KattSafe"
$frontendDir = "$baseDir\pdf-qa-frontend"
$backendDir = "$baseDir\backend"

# 第1步：复制PDF文件到后端
Write-Host "`n📁 第1步：复制PDF文件到后端..." -ForegroundColor Green

if (-not (Test-Path "$backendDir\pdfs")) {
    New-Item -ItemType Directory -Path "$backendDir\pdfs" -Force
    Write-Host "   ✓ 创建后端PDF目录" -ForegroundColor Gray
}

$pdfFiles = @(
    "harness-gear-operation-manual.pdf",
    "2920-sp391-sp392-skylight-mesh-fixing-details-with-clip.pdf"
)

foreach ($pdf in $pdfFiles) {
    $sourcePath = "$baseDir\$pdf"
    $destPath = "$backendDir\pdfs\$pdf"
    
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $destPath -Force
        Write-Host "   ✓ 复制 $pdf" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠ 未找到 $pdf" -ForegroundColor Yellow
    }
}

# 第2步：检查前端环境变量
Write-Host "`n🔧 第2步：检查前端配置..." -ForegroundColor Green

$envPath = "$frontendDir\.env"
if (Test-Path $envPath) {
    Write-Host "   ✓ .env 文件已存在" -ForegroundColor Gray
} else {
    Write-Host "   ⚠ 需要创建 .env 文件" -ForegroundColor Yellow
}

# 第3步：安装依赖
Write-Host "`n📦 第3步：检查依赖..." -ForegroundColor Green

# 检查 Node.js
try {
    $nodeVersion = node --version
    Write-Host "   ✓ Node.js: $nodeVersion" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Node.js 未安装" -ForegroundColor Red
}

# 检查 npm
try {
    $npmVersion = npm --version
    Write-Host "   ✓ npm: $npmVersion" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ npm 未安装" -ForegroundColor Red
}

# 检查前端依赖
if (Test-Path "$frontendDir\node_modules") {
    Write-Host "   ✓ 前端依赖已安装" -ForegroundColor Gray
} else {
    Write-Host "   ⚠ 需要安装前端依赖: cd pdf-qa-frontend && npm install" -ForegroundColor Yellow
}

# 第4步：显示部署命令
Write-Host "`n🚀 第4步：部署命令" -ForegroundColor Green

Write-Host "`n   后端部署 (Railway):" -ForegroundColor Cyan
Write-Host "   1. 访问 https://railway.app" -ForegroundColor Gray
Write-Host "   2. 连接 GitHub 仓库" -ForegroundColor Gray
Write-Host "   3. 选择 backend/ 目录" -ForegroundColor Gray
Write-Host "   4. 配置环境变量" -ForegroundColor Gray

Write-Host "`n   前端部署 (Vercel):" -ForegroundColor Cyan
Write-Host "   1. npm install -g vercel" -ForegroundColor Gray
Write-Host "   2. cd pdf-qa-frontend" -ForegroundColor Gray
Write-Host "   3. vercel login" -ForegroundColor Gray
Write-Host "   4. vercel --prod" -ForegroundColor Gray

# 第5步：环境变量提醒
Write-Host "`n⚙️ 第5步：环境变量配置" -ForegroundColor Green

Write-Host "`n   前端 (.env):" -ForegroundColor Cyan
@"
   REACT_APP_API_URL=https://your-backend.railway.app
"@ | Write-Host -ForegroundColor Gray

Write-Host "`n   后端 (Railway环境变量):" -ForegroundColor Cyan
@"
   AZURE_OPENAI_API_KEY=您的Azure密钥
   AZURE_OPENAI_ENDPOINT=https://azureaitestenv.cognitiveservices.azure.com/
   AZURE_OPENAI_DEPLOYMENT=gpt-4
   CORS_ORIGINS=https://your-frontend.vercel.app
"@ | Write-Host -ForegroundColor Gray

# 第6步：测试命令
Write-Host "`n🧪 第6步：测试命令" -ForegroundColor Green

Write-Host "`n   本地测试后端:" -ForegroundColor Cyan
Write-Host "   cd backend && python main.py" -ForegroundColor Gray

Write-Host "`n   本地测试前端:" -ForegroundColor Cyan
Write-Host "   cd pdf-qa-frontend && npm start" -ForegroundColor Gray

Write-Host "`n   生产环境测试:" -ForegroundColor Cyan
Write-Host "   curl https://your-backend.railway.app/health" -ForegroundColor Gray

# 总结
Write-Host "`n"+"="*70 -ForegroundColor Cyan
Write-Host "    部署准备完成！" -ForegroundColor Yellow
Write-Host "="*70 -ForegroundColor Cyan

Write-Host "`n📋 下一步操作:" -ForegroundColor Green
Write-Host "   1. 部署后端到 Railway" -ForegroundColor White
Write-Host "   2. 获取后端URL" -ForegroundColor White  
Write-Host "   3. 更新前端 .env 文件" -ForegroundColor White
Write-Host "   4. 部署前端到 Vercel" -ForegroundColor White
Write-Host "   5. 配置 CORS 域名" -ForegroundColor White

Write-Host "`n🔗 有用链接:" -ForegroundColor Green
Write-Host "   Railway: https://railway.app" -ForegroundColor Blue
Write-Host "   Vercel:  https://vercel.com" -ForegroundColor Blue
Write-Host "   文档:    vercel-deployment-complete-guide.md" -ForegroundColor Blue

Write-Host "`n✅ 准备工作完成！开始部署吧！" -ForegroundColor Green
