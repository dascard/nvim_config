#!/bin/bash
# Neovim 配置安装脚本 (Linux/Unix)
# 作者: dascard

set -e

echo "Installing Neovim configuration dependencies..."

# 检测包管理器
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install -y"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    UPDATE_CMD="sudo pacman -Sy"
    INSTALL_CMD="sudo pacman -S --noconfirm"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
    UPDATE_CMD="sudo yum update"
    INSTALL_CMD="sudo yum install -y"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="sudo dnf update"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "Unsupported package manager. Please install manually."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# 更新包管理器
echo "Updating package manager..."
$UPDATE_CMD

# 安装基础包
echo "Installing basic packages..."
case $PKG_MANAGER in
    "apt")
        $INSTALL_CMD git neovim nodejs npm python3 python3-pip build-essential \
                     xclip wl-clipboard curl wget
        ;;
    "pacman")
        $INSTALL_CMD git neovim nodejs npm python python-pip base-devel \
                     xclip wl-clipboard curl wget
        ;;
    "yum"|"dnf")
        $INSTALL_CMD git neovim nodejs npm python3 python3-pip gcc gcc-c++ make \
                     xclip wl-clipboard curl wget
        ;;
esac

# 安装开发工具
echo "Installing development tools..."

# Python 工具
echo "Installing Python tools..."
pip3 install --user black pyright

# Node.js 工具
echo "Installing Node.js tools..."
sudo npm install -g prettier eslint typescript-language-server

# 安装 Nerd Font 字体
echo "Installing Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "Downloading JetBrains Mono Nerd Font..."
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    TEMP_ZIP="/tmp/JetBrainsMono.zip"
    
    if command -v curl >/dev/null 2>&1; then
        curl -fLo "$TEMP_ZIP" "$FONT_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$TEMP_ZIP" "$FONT_URL"
    else
        echo "Warning: curl or wget not found. Please install font manually."
    fi
    
    if [ -f "$TEMP_ZIP" ]; then
        unzip -o "$TEMP_ZIP" -d "$FONT_DIR" "*.ttf"
        rm -f "$TEMP_ZIP"
        
        # 刷新字体缓存
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f -v
            echo "Font installed and cache updated"
        else
            echo "Font installed. Please restart your terminal to use the new font."
        fi
    fi
else
    echo "JetBrains Mono Nerd Font already installed"
fi

# 创建符号链接 (如果需要)
if ! command -v nvim >/dev/null 2>&1; then
    if command -v neovim >/dev/null 2>&1; then
        sudo ln -sf $(which neovim) /usr/local/bin/nvim
    fi
fi

echo "Installation completed!"
echo "Next steps:"
echo "1. Start Neovim: nvim"
echo "2. Run :checkhealth in Neovim"
