@echo off
REM Neovim 配置快速安装脚本 (Windows)
REM 作者: dascard
REM 描述: 自动安装和配置 Neovim 开发环境

setlocal enabledelayedexpansion

echo.
echo ========================================
echo    Neovim 配置安装工具 - Windows
echo    作者: dascard
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [警告] 建议以管理员身份运行此脚本
    echo.
    set /p continue="是否继续安装? (Y/N): "
    if /i not "!continue!"=="Y" (
        echo 安装已取消
        pause
        exit /b 1
    )
)

REM 检查 PowerShell 版本
powershell -Command "if ($PSVersionTable.PSVersion.Major -lt 3) { exit 1 }"
if %errorLevel% neq 0 (
    echo [错误] 需要 PowerShell 3.0 或更高版本
    pause
    exit /b 1
)

echo [信息] 开始安装依赖项...
echo.

REM 检查 winget
winget --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [警告] winget 未安装，将尝试使用其他方法
    set USE_WINGET=false
) else (
    echo [信息] 检测到 winget 包管理器
    set USE_WINGET=true
)

echo.
echo [1/6] 安装 Git...
if "%USE_WINGET%"=="true" (
    winget install --id Git.Git --silent --accept-source-agreements --accept-package-agreements
) else (
    echo 请手动从 https://git-scm.com/download/win 安装 Git
    pause
)

echo.
echo [2/6] 安装 Node.js...
if "%USE_WINGET%"=="true" (
    winget install --id OpenJS.NodeJS --silent --accept-source-agreements --accept-package-agreements
) else (
    echo 请手动从 https://nodejs.org/en/download/ 安装 Node.js
    pause
)

echo.
echo [3/6] 安装 Python...
if "%USE_WINGET%"=="true" (
    winget install --id Python.Python.3 --silent --accept-source-agreements --accept-package-agreements
) else (
    echo 请手动从 https://www.python.org/downloads/ 安装 Python
    pause
)

echo.
echo [4/6] 安装 Rust...
if "%USE_WINGET%"=="true" (
    winget install --id Rustlang.Rustup --silent --accept-source-agreements --accept-package-agreements
) else (
    echo 请手动从 https://rustup.rs/ 安装 Rust
    pause
)

echo.
echo [5/6] 安装 LLVM/Clang...
if "%USE_WINGET%"=="true" (
    winget install --id LLVM.LLVM --silent --accept-source-agreements --accept-package-agreements
) else (
    echo 请手动从 https://llvm.org/releases/ 安装 LLVM
    pause
)

echo.
echo [6/6] 安装 Neovim...
if "%USE_WINGET%"=="true" (
    winget install --id Neovim.Neovim --silent --accept-source-agreements --accept-package-agreements
) else (
    echo 请手动从 https://github.com/neovim/neovim/releases 安装 Neovim
    pause
)

echo.
echo [信息] 基础安装完成，现在安装开发工具...
echo.

REM 刷新环境变量
call refreshenv.cmd >nul 2>&1

REM 安装 Python 包
echo [Python] 安装开发工具...
python -m pip install --upgrade pip
python -m pip install --user black autopep8 isort flake8 pylint pyright debugpy pytest

REM 安装 Node.js 包
echo.
echo [Node.js] 安装开发工具...
call npm install -g prettier @fsouza/prettierd eslint eslint_d typescript-language-server @typescript-eslint/parser typescript @types/node

REM 安装 Rust 工具
echo.
echo [Rust] 安装开发工具...
call cargo install stylua ripgrep fd-find bat

echo.
echo [信息] 创建配置检查脚本...

REM 创建健康检查脚本
(
echo @echo off
echo echo.
echo echo ========================================
echo echo    Neovim 配置健康检查
echo echo ========================================
echo echo.
echo.
echo set TOOLS=nvim git node npm python pip cargo rustc clang
echo.
echo for %%i in ^(%%TOOLS%%^) do ^(
echo     %%i --version ^>nul 2^>^&1
echo     if ^^!errorLevel^^! equ 0 ^(
echo         echo [OK] %%i 已安装
echo     ^) else ^(
echo         echo [NO] %%i 未找到
echo     ^)
echo ^)
echo.
echo echo.
echo echo 建议在 Neovim 中运行以下命令:
echo echo   :checkhealth
echo echo   :CocInfo
echo echo   :Lazy
echo echo.
echo pause
) > health-check.bat

echo.
echo ========================================
echo    安装完成!
echo ========================================
echo.
echo 下一步:
echo   1. 重启命令提示符以刷新环境变量
echo   2. 运行 health-check.bat 检查安装状态
echo   3. 启动 Neovim: nvim
echo   4. 等待插件自动安装完成
echo   5. 在 Neovim 中运行 :checkhealth
echo.
echo 如果遇到问题，请查看 README.md 中的故障排除部分
echo.

pause
