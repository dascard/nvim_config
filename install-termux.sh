#!/data/data/com.termux/files/usr/bin/bash
# Neovim 配置安装脚本 (Termux)
# 作者: dascard

set -e

echo "🚀 Installing Neovim configuration dependencies for Termux..."

# 更新包
echo "📦 Updating packages..."
pkg update && pkg upgrade

# 安装基础包
echo "🔧 Installing basic packages..."
pkg install -y git neovim nodejs python curl wget unzip

# 安装编译工具和依赖
echo "🛠️ Installing build tools..."
pkg install -y make cmake clang binutils

# 安装编程语言和工具
echo "💻 Installing programming languages..."
pkg install -y golang rust lua54 luarocks ruby php

# 安装系统工具
echo "⚙️ Installing system utilities..."
pkg install -y ripgrep fd fzf tree bat exa htop ncdu

# 安装字体和终端工具
echo "🎨 Installing terminal enhancements..."
pkg install -y termux-api man

# Python 工具
echo "🐍 Installing Python tools..."
pip install --upgrade pip
pip install black isort pyright autopep8 flake8 mypy pynvim

# Node.js 工具
echo "📦 Installing Node.js tools..."
npm install -g prettier eslint typescript-language-server \
    @fsouza/prettierd eslint_d vscode-langservers-extracted \
    typescript pyright bash-language-server

# Rust 工具
echo "🦀 Installing Rust tools..."
cargo install tree-sitter-cli

# Go 工具
echo "🐹 Installing Go tools..."
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/gopls@latest

# Ruby 工具
echo "💎 Installing Ruby tools..."
gem install solargraph

# 安装 Nerd Font 字体
echo "🎨 Installing Nerd Font..."
if [ ! -d "$HOME/.termux/font" ]; then
    mkdir -p $HOME/.termux
    echo "Downloading JetBrains Mono Nerd Font..."
    curl -fLo "$HOME/.termux/font.ttf" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" || \
    wget -O "$HOME/.termux/font.ttf" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    
    if [ -f "$HOME/.termux/font.ttf" ]; then
        echo "Font downloaded. Please restart Termux to apply the font."
    else
        echo "Font download failed. You can manually download from: https://github.com/ryanoasis/nerd-fonts"
    fi
fi

# 设置存储访问 (可选)
if [ ! -d "$HOME/storage" ]; then
    echo "📱 To access device storage, run: termux-setup-storage"
fi

echo ""
echo "✅ Installation completed!"
echo ""
echo "Next steps:"
echo "1. Restart Termux to apply font changes"
echo "2. Start Neovim: nvim"
echo "3. Run health check: :checkhealth"
echo "4. (Optional) Set up storage access: termux-setup-storage"
