# ✅ Vercel 部署检查清单

## 📋 准备工作 (已完成)

- [x] ✅ PDF文件已复制到 `backend/pdfs/` 
- [x] ✅ 后端代码已创建 (`backend/main.py`, `backend/pdf_qa.py`)
- [x] ✅ 前端环境变量配置已创建 (`pdf-qa-frontend/.env`)
- [x] ✅ Vercel配置文件已创建 (`vercel.json`)
- [x] ✅ 部署指南已创建

## 🔄 接下来的部署步骤

### 步骤1️⃣: 后端部署到 Railway (推荐)

1. **注册Railway账户**
   - 访问: https://railway.app
   - 用GitHub账户登录

2. **创建新项目**
   - 点击 "New Project"
   - 选择 "Deploy from GitHub repo"
   - 选择您的 KattSafe 仓库
   - 选择 `backend` 目录作为根目录

3. **配置环境变量** (重要!)
   ```
   AZURE_OPENAI_API_KEY=8OgwTbueNSFrNWeEUZ2tOgnlVwYC7PXLiULoOZKz6JQgWkNcWjucJQQJ99BHACL93NaXJ3w3AAAAACOGzn2y
   AZURE_OPENAI_ENDPOINT=https://azureaitestenv.cognitiveservices.azure.com/
   AZURE_OPENAI_DEPLOYMENT=gpt-4
   AZURE_OPENAI_API_VERSION=2024-02-01
   CORS_ORIGINS=https://your-frontend.vercel.app,http://localhost:3000
   PORT=8000
   PDF_BASE_PATH=/app/pdfs
   ```

4. **等待部署完成**
   - Railway会自动检测Python项目
   - 安装requirements.txt中的依赖
   - 启动FastAPI服务器

5. **获取后端URL**
   - 部署完成后，您会得到类似: `https://your-backend.railway.app`

### 步骤2️⃣: 前端部署到 Vercel

1. **安装Vercel CLI**
   ```powershell
   npm install -g vercel
   ```

2. **更新前端环境变量**
   编辑 `pdf-qa-frontend/.env`:
   ```
   REACT_APP_API_URL=https://your-backend.railway.app
   ```
   ⚠️ 替换为您实际的Railway后端URL

3. **登录Vercel**
   ```powershell
   vercel login
   ```

4. **部署前端**
   ```powershell
   cd pdf-qa-frontend
   vercel --prod
   ```

5. **配置项目设置**
   - 选择项目名称
   - 选择团队 (个人账户)
   - 确认设置

### 步骤3️⃣: 更新CORS配置

1. **获取前端URL**
   - Vercel部署完成后，您会得到: `https://your-app.vercel.app`

2. **更新Railway环境变量**
   - 进入Railway项目设置
   - 更新 `CORS_ORIGINS` 为实际的Vercel URL:
   ```
   CORS_ORIGINS=https://your-app.vercel.app,http://localhost:3000
   ```

3. **重新部署后端** (如果需要)
   - Railway通常会自动重启

## 🧪 测试部署

### 测试后端API
```powershell
# 健康检查
curl https://your-backend.railway.app/health

# 获取API文档
# 在浏览器打开: https://your-backend.railway.app/docs
```

### 测试前端
```powershell
# 在浏览器打开: https://your-app.vercel.app
```

## 🔧 替代方案: 本地部署测试

如果想先在本地测试整个流程:

1. **启动后端**
   ```powershell
   cd backend
   pip install -r requirements.txt
   python main.py
   ```

2. **启动前端**
   ```powershell
   cd pdf-qa-frontend
   npm install
   npm start
   ```

3. **在浏览器测试**
   - 前端: http://localhost:3000
   - 后端API: http://localhost:8000/docs

## 📝 部署时间估算

- **后端部署 (Railway)**: 5-10分钟
- **前端部署 (Vercel)**: 2-5分钟  
- **DNS传播**: 1-5分钟
- **总计**: 约15-20分钟

## 🚨 常见问题

### 1. CORS错误
- 确保Railway中的 `CORS_ORIGINS` 包含正确的Vercel URL

### 2. API调用失败
- 检查 `REACT_APP_API_URL` 是否正确
- 确保Railway后端正常运行

### 3. PDF文件未找到
- 确认PDF文件已复制到 `backend/pdfs/` 目录
- 检查文件名是否正确

### 4. Azure OpenAI错误
- 验证API密钥是否正确
- 检查额度是否充足

## 🎯 成功标志

✅ 后端健康检查返回200状态码
✅ 前端加载无错误
✅ 能够成功提问并获得回答
✅ PDF列表显示正确
✅ OCR功能正常工作

## 🔗 最终URLs

完成部署后，您将拥有:
- **生产前端**: https://your-app.vercel.app
- **生产API**: https://your-backend.railway.app
- **API文档**: https://your-backend.railway.app/docs

现在可以开始部署了！🚀
