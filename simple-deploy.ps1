# KattSafe PDF QA - Simple Deploy Script

Write-Host "=== KattSafe PDF QA - Deploy Helper ===" -ForegroundColor Cyan

# Check if in correct directory
if (-not (Test-Path "pdf-qa-frontend")) {
    Write-Host "Error: Please run this script from KattSafe root directory" -ForegroundColor Red
    exit 1
}

# Step 1: Check dependencies
Write-Host "`nStep 1: Checking dependencies..." -ForegroundColor Green

try {
    $nodeVersion = node --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Gray
} catch {
    Write-Host "Node.js not installed. Please install Node.js first" -ForegroundColor Red
    exit 1
}

try {
    $npmVersion = npm --version  
    Write-Host "npm: $npmVersion" -ForegroundColor Gray
} catch {
    Write-Host "npm not installed" -ForegroundColor Red
    exit 1
}

# Step 2: Install frontend dependencies
Write-Host "`nStep 2: Installing frontend dependencies..." -ForegroundColor Green
Set-Location "pdf-qa-frontend"

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    Write-Host "Dependencies installed" -ForegroundColor Gray
} else {
    Write-Host "Dependencies already exist" -ForegroundColor Gray
}

# Step 3: Check environment variables  
Write-Host "`nStep 3: Checking environment variables..." -ForegroundColor Green

if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    @"
# Development environment
REACT_APP_API_URL=http://localhost:8000

# Production environment - Update this URL after deploying backend
# REACT_APP_API_URL=https://your-backend.railway.app
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host ".env file created" -ForegroundColor Gray
} else {
    Write-Host ".env file already exists" -ForegroundColor Gray
}

# Step 4: Check Vercel CLI
Write-Host "`nStep 4: Checking Vercel CLI..." -ForegroundColor Green

try {
    $vercelVersion = vercel --version
    Write-Host "Vercel CLI: $vercelVersion" -ForegroundColor Gray
} catch {
    Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
    Write-Host "Vercel CLI installed" -ForegroundColor Gray
}

# Back to root directory
Set-Location ".."

# Step 5: Show deployment instructions
Write-Host "`nStep 5: Deployment Instructions" -ForegroundColor Green
Write-Host "Backend Deployment (Railway):" -ForegroundColor Cyan
Write-Host "1. Visit https://railway.app" -ForegroundColor White
Write-Host "2. Connect your GitHub repository" -ForegroundColor White
Write-Host "3. Select backend/ directory" -ForegroundColor White
Write-Host "4. Configure environment variables" -ForegroundColor White

Write-Host "`nFrontend Deployment (Vercel):" -ForegroundColor Cyan
Write-Host "1. cd pdf-qa-frontend" -ForegroundColor White  
Write-Host "2. vercel login" -ForegroundColor White
Write-Host "3. vercel --prod" -ForegroundColor White
Write-Host "4. Configure REACT_APP_API_URL in Vercel dashboard" -ForegroundColor White

Write-Host "`nReady to deploy!" -ForegroundColor Green

# Ask if user wants to start deployment
$choice = Read-Host "`nDo you want to login to Vercel now? (y/n)"
if ($choice -eq "y" -or $choice -eq "Y") {
    Write-Host "`nStarting Vercel deployment..." -ForegroundColor Cyan
    Set-Location "pdf-qa-frontend"
    vercel login
    
    $deployChoice = Read-Host "`nContinue with production deployment? (y/n)"
    if ($deployChoice -eq "y" -or $deployChoice -eq "Y") {
        vercel --prod
    }
}

Write-Host "`nScript completed!" -ForegroundColor Green
Write-Host "`nUseful links:" -ForegroundColor Cyan
Write-Host "Vercel Dashboard: https://vercel.com/dashboard" -ForegroundColor Blue
Write-Host "Railway Dashboard: https://railway.app/dashboard" -ForegroundColor Blue
