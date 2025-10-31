# Neovim 配置安装脚本 (Windows)
# 作者: dascard

Write-Host "Installing Neovim configuration dependencies..." -ForegroundColor Green

# 检查 winget 是否可用
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget 未安装。请先安装 winget 或手动安装依赖。"
    exit 1
}

# 安装基础包
Write-Host "Installing basic packages..." -ForegroundColor Yellow

$packages = @(
    "Git.Git",
    "Neovim.Neovim", 
    "OpenJS.NodeJS",
    "Python.Python.3"
)

# 安装剪切板工具
$clipboardTools = @(
    "equalsraf.win32yank"
)

Write-Host "Installing clipboard tools..." -ForegroundColor Yellow
foreach ($tool in $clipboardTools) {
    Write-Host "Installing $tool..." -ForegroundColor Cyan
    winget install --id $tool --silent --accept-source-agreements --accept-package-agreements 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install $tool via winget, trying alternative method..." -ForegroundColor Yellow
        # 备用安装方法
        if ($tool -eq "equalsraf.win32yank") {
            Write-Host "Downloading win32yank from GitHub..." -ForegroundColor Cyan
            $url = "https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip"
            $downloadPath = "$env:TEMP\win32yank.zip"
            $extractPath = "$env:LOCALAPPDATA\win32yank"
            
            try {
                Invoke-WebRequest -Uri $url -OutFile $downloadPath
                Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
                
                # 添加到 PATH
                $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
                if ($currentPath -notlike "*$extractPath*") {
                    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$extractPath", "User")
                    Write-Host "Added win32yank to PATH" -ForegroundColor Green
                }
                Remove-Item $downloadPath -Force
            } catch {
                Write-Host "Failed to install win32yank: $_" -ForegroundColor Red
            }
        }
    }
}

foreach ($pkg in $packages) {
    Write-Host "Installing $pkg..." -ForegroundColor Cyan
    winget install --id $pkg --silent --accept-source-agreements --accept-package-agreements
}

# 安装开发工具包
Write-Host "Installing development tools..." -ForegroundColor Yellow

# Python 工具
Write-Host "Installing Python tools..." -ForegroundColor Cyan
pip install --user black pyright

# Node.js 工具
Write-Host "Installing Node.js tools..." -ForegroundColor Cyan  
npm install -g prettier eslint typescript-language-server

# 安装 Nerd Font 字体
Write-Host "Installing Nerd Font..." -ForegroundColor Yellow

# 尝试通过 winget 安装
$fontInstalled = $false
try {
    winget install --id "DEVCOM.JetBrainsMonoNerdFont" --silent --accept-source-agreements --accept-package-agreements
    Write-Host "JetBrains Mono Nerd Font installed via winget" -ForegroundColor Green
    $fontInstalled = $true
} catch {
    Write-Host "Winget installation failed, trying alternative method..." -ForegroundColor Yellow
}

# 备用安装方法
if (-not $fontInstalled) {
    try {
        $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        $fontZip = "$env:TEMP\JetBrainsMono.zip"
        $fontDir = "$env:TEMP\JetBrainsMono"
        
        Write-Host "Downloading JetBrains Mono Nerd Font..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
        
        # 解压字体文件
        Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
        
        # 安装字体
        $shell = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.Namespace(0x14)
        
        Get-ChildItem "$fontDir\*.ttf" | ForEach-Object {
            $fontsFolder.CopyHere($_.FullName)
        }
        
        # 清理临时文件
        Remove-Item $fontZip -Force
        Remove-Item $fontDir -Recurse -Force
        
        Write-Host "JetBrains Mono Nerd Font installed manually" -ForegroundColor Green
    } catch {
        Write-Warning "Font installation failed. Please install manually from: https://github.com/ryanoasis/nerd-fonts"
        Write-Host "Manual installation: Download JetBrainsMono.zip and install .ttf files" -ForegroundColor Yellow
    }
}

Write-Host "Installation completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart your terminal"
Write-Host "2. Start Neovim: nvim"
Write-Host "3. Run :checkhealth in Neovim"
