qing# Neovim 配置

作者: **dascard**

这是一个功能丰富、高度优化的 Neovim 配置，基于 lazy.nvim 插件管理器构建，专为提升开发效率而设计。配置支持多种编程语言和开发工具，提供完整的 IDE 体验。

## 📋 目录

- [✨ 核心特性](#-核心特性)
- [🛠️ 安装](#️-安装)
- [⚙️ 系统依赖](#️-系统依赖)
- [⌨️ 快捷键映射](#️-快捷键映射)
- [📁 配置结构](#-配置结构)
- [🧩 主要插件](#-主要插件)
- [💻 支持的编程语言](#-支持的编程语言)
- [🔧 维护和管理](#-维护和管理)
- [❓ 常见问题和故障排除](#-常见问题和故障排除)
- [🤝 贡献指南](#-贡献指南)
- [📄 许可证](#-许可证)

## ✨ 核心特性

### 🚀 现代化体验
- **插件管理**: 使用 [lazy.nvim](https://github.com/folke/lazy.nvim) 实现快速启动和延迟加载
- **智能补全**: COC.nvim + nvim-cmp 双重补全系统
- **AI 助手**: 集成 GitHub Copilot，提供智能代码建议和对话
- **主题**: 精美的 Tokyo Night 主题，支持多种变体

### 🔧 开发工具
- **语言服务**: COC.nvim 提供稳定的 LSP 支持，涵盖 20+ 编程语言
- **调试系统**: nvim-dap 支持多语言调试，包括远程调试和容器调试
- **测试框架**: neotest 集成，支持 pytest、jest、go test 等
- **任务运行**: overseer.nvim 和 asynctasks.vim 双重任务管理

### 📁 界面和导航
- **文件浏览**: nvim-tree 文件管理器
- **模糊搜索**: telescope.nvim 和 fzf 集成
- **项目管理**: 自动项目检测和会话管理
- **缓冲区**: bufferline.nvim 美观的标签页管理

### 🎯 编辑增强
- **代码折叠**: nvim-ufo 智能折叠
- **快速跳转**: flash.nvim 精准导航
- **环绕操作**: nvim-surround 高效编辑
- **自动配对**: 智能括号和引号配对

### 🐛 调试和测试
- **多语言调试**: 支持 Python、JavaScript、Go、Rust、C/C++、Java 等
- **远程调试**: SSH 和 Docker 容器调试支持
- **测试集成**: 内置测试发现和执行
- **性能分析**: 调试性能分析工具

### 🔍 代码质量
- **Lint 检查**: eslint、pylint、shellcheck 等集成
- **格式化**: prettier、black、rustfmt 等格式化工具
- **Git 集成**: gitsigns.nvim 提供 Git 状态显示
- **TODO 管理**: 智能 TODO 注释追踪

### 🌐 特殊支持
- **数据库**: 内置数据库客户端和查询工具
- **Markdown**: 实时预览和渲染
- **文档编写**: Typst 和 LaTeX 支持
- **Web 开发**: HTML/CSS/JavaScript 完整工具链

## 🛠️ 安装

1. 备份现有配置：
```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.local/state/nvim ~/.local/state/nvim.backup
```

2. 克隆此配置：
```bash
git clone https://github.com/dascard/nvim_config ~/.config/nvim
```

3. 运行安装脚本（可选，自动安装依赖）：

**Windows (PowerShell):**
```powershell
.\install.ps1
```

**Linux/macOS:**
```bash
chmod +x install.sh
./install.sh
```

**Termux (Android):**
```bash
chmod +x install-termux.sh
./install-termux.sh
```

4. 启动 Neovim：
```bash
nvim
```

插件将自动安装。

## 系统依赖

### 自动安装脚本

本配置提供了三个安装脚本，可以自动安装大部分依赖和字体：
- `install.ps1` - Windows PowerShell 脚本（包含 JetBrains Mono Nerd Font）
- `install.sh` - Linux/macOS 安装脚本（包含字体安装）
- `install-termux.sh` - Android Termux 专用脚本（简化版，包含字体）

所有脚本都会自动安装：
- 基本开发工具（Git、Node.js、Python）
- 剪切板工具（跨平台适配）
- JetBrains Mono Nerd Font 字体
- 语言服务器和格式化工具

### 手动安装依赖

在使用此配置之前，请确保已安装以下命令行工具：

#### 核心工具
```bash
# Git (版本控制)
sudo apt install git
# 或 Windows: winget install Git.Git

# Node.js 和 npm (JavaScript 生态系统)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
# 或 Windows: winget install OpenJS.NodeJS

# Python 3 和 pip (Python 生态系统)
sudo apt install python3 python3-pip
# 或 Windows: winget install Python.Python.3

# Rust 和 Cargo (Rust 生态系统)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# 或 Windows: winget install Rustlang.Rustup
```

#### 语言服务器和调试器依赖
```bash
# C/C++ 开发
sudo apt install build-essential clang clangd gdb lldb
# Windows: winget install LLVM.LLVM

# Go 开发
sudo apt install golang-go
# 安装 Delve 调试器
go install github.com/go-delve/delve/cmd/dlv@latest
# Windows: winget install GoLang.Go

# Java 开发 (可选)
sudo apt install openjdk-17-jdk
# Windows: winget install Eclipse.Temurin.17.JDK

# PHP 开发
sudo apt install php php-cli php-xdebug
# Windows: winget install PHP.PHP

# Ruby 开发
sudo apt install ruby ruby-dev
gem install readapt

# .NET 开发
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update && sudo apt install -y dotnet-sdk-8.0
```

#### 格式化和检查工具
```bash
# 通用格式化工具
npm install -g prettier
npm install -g @fsouza/prettierd

# JavaScript/TypeScript 工具
npm install -g eslint
npm install -g eslint_d
npm install -g typescript-language-server
npm install -g @typescript-eslint/parser

# Python 工具
pip3 install black autopep8 isort flake8 pylint pyright

# Lua 工具
cargo install stylua

# Shell 脚本检查
sudo apt install shellcheck
# Windows: winget install koalaman.shellcheck

# Docker
sudo apt install docker.io
# 安装 hadolint (Dockerfile 检查)
sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64
sudo chmod +x /bin/hadolint
```

#### 数据库工具 (可选)
```bash
# SQLite
sudo apt install sqlite3
# MySQL/MariaDB 客户端
sudo apt install mysql-client
# PostgreSQL 客户端
sudo apt install postgresql-client
```

#### 字体安装 (推荐)
```bash
# Nerd Fonts - 提供图标支持
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv

# Windows: 下载并安装 JetBrains Mono Nerd Font
# https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
```

### Windows 特定配置

对于 Windows 用户，推荐使用以下工具：

```powershell
# 安装 Chocolatey 包管理器
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 使用 Chocolatey 安装基础工具
choco install git nodejs python rust llvm golang openjdk php ruby dotnet-sdk

# 使用 winget 安装工具 (Windows 10/11)
winget install Git.Git
winget install OpenJS.NodeJS
winget install Python.Python.3
winget install Rustlang.Rustup
winget install LLVM.LLVM
winget install GoLang.Go
```

### 可选增强工具

```bash
# ripgrep (更快的搜索)
sudo apt install ripgrep
# 或: cargo install ripgrep

# fd (更快的文件搜索)
sudo apt install fd-find
# 或: cargo install fd-find

# bat (更好的 cat 替代)
sudo apt install bat
# 或: cargo install bat

# fzf (模糊搜索)
sudo apt install fzf
# 或: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# lazygit (Git TUI)
sudo add-apt-repository ppa:lazygit-team/release
sudo apt update && sudo apt install lazygit
```

### 配置检查

安装完成后，可以使用以下命令检查配置状态：

```vim
:checkhealth
```

这将显示所有依赖项的安装状态和配置建议。

## 快捷键映射

### 基础设置
- **Leader 键**: `;` (分号)
- **Local Leader 键**: `;` (分号)

### 通用快捷键

#### 窗口管理
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<Left>` | Normal | 移动到左侧窗口 |
| `<Right>` | Normal | 移动到右侧窗口 |
| `<Up>` | Normal | 移动到上方窗口 |
| `<Down>` | Normal | 移动到下方窗口 |
| `<C-x>` | Normal | 交换窗口 |

#### 光标移动
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `H` | Normal/Visual | 跳转到行首 |
| `L` | Normal/Visual | 跳转到行尾 |
| `J` | Normal/Visual | 向下跳转 15 行 |
| `K` | Normal/Visual | 向上跳转 15 行 |
| `j` | Normal | 向下移动（处理换行） |
| `k` | Normal | 向上移动（处理换行） |
| `<C-e>` | Normal | 跳转到匹配的括号 |

#### 编辑操作
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>ss` | Normal | 搜索替换 |
| `Q` | Normal | 格式化段落 |
| `<M-o>` | Normal | 在下方插入空行 |

#### 插入模式
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `jk` | Insert | 退出插入模式 |
| `<leader>a` | Insert | 退出插入模式并跳转到行尾 |
| `<C-o>` | Insert | 退出插入模式并在下方新增一行 |
| `,` | Insert | 插入逗号并设置撤销点 |
| `.` | Insert | 插入句号并设置撤销点 |
| `;` | Insert | 插入分号并设置撤销点 |

#### 可视模式
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<C-j>` | Visual | 向下移动选中的行 |
| `<C-k>` | Visual | 向上移动选中的行 |
| `<Tab>` | Visual | 增加缩进 |
| `<S-Tab>` | Visual | 减少缩进 |

### 插件快捷键

#### Copilot AI 助手
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<C-}>` | Insert | 上一个 Copilot 建议 |
| `<C-]>` | Insert | 下一个 Copilot 建议 |

#### 文件管理器 (nvim-tree)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>e` | Normal | 切换文件管理器 |
| `l` | Normal (在 nvim-tree 中) | 打开文件/展开目录 |
| `h` | Normal (在 nvim-tree 中) | 关闭目录 |
| `o` | Normal (在 nvim-tree 中) | 垂直分割打开文件 |
| `<C-t>` | Normal (在 nvim-tree 中) | 返回上级目录 |
| `<BS>` | Normal (在 nvim-tree 中) | 返回上级目录 |
| `?` | Normal (在 nvim-tree 中) | 显示帮助 |

#### 缓冲区管理 (bufferline)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<S-h>` | Normal | 上一个缓冲区 |
| `<S-l>` | Normal | 下一个缓冲区 |
| `<leader>[` | Normal | 上一个缓冲区 |
| `<leader>]` | Normal | 下一个缓冲区 |
| `[B` | Normal | 向前移动缓冲区 |
| `]B` | Normal | 向后移动缓冲区 |
| `<leader>bp` | Normal | 固定/取消固定缓冲区 |
| `<leader>bP` | Normal | 删除未固定的缓冲区 |
| `<leader>br` | Normal | 删除右侧缓冲区 |
| `<leader>bl` | Normal | 删除左侧缓冲区 |

#### 标签页管理
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<M-n>` | Normal | 下一个标签页 |
| `<M-p>` | Normal | 上一个标签页 |

#### LSP 功能
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `gd` | Normal | 跳转到定义 |
| `K` | Normal | 显示悬停信息 |
| `gi` | Normal | 跳转到实现 |
| `<C-k>` | Normal | 显示签名帮助 |
| `gr` | Normal | 查找引用 |
| `<leader>rn` | Normal | 重命名符号 |
| `<leader>ca` | Normal/Visual | 代码操作 |
| `<leader>f` | Normal | 格式化代码 |
| `<leader>D` | Normal | 类型定义 |
| `<leader>wa` | Normal | 添加工作区文件夹 |
| `<leader>wr` | Normal | 移除工作区文件夹 |
| `<leader>wl` | Normal | 列出工作区文件夹 |
| `<leader>cf` | Normal | 快速修复 |

#### 代码折叠 (UFO)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `zO` | Normal | 打开所有折叠 |
| `zC` | Normal | 关闭所有折叠 |
| `zr` | Normal | 打开除当前以外的所有折叠 |
| `<leader>K` | Normal | 预览折叠内容 |

#### 调试 (DAP)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<F5>` | Normal | 启动/继续调试 |
| `<leader>dp` | Normal | 切换断点 |
| `<leader>dc` | Normal | 继续执行 |
| `<leader>dtc` | Normal | 运行到光标 |
| `<leader>dT` | Normal | 终止调试 |
| `<space><space>` | Normal | 单步跳过 |
| `<leader>di` | Normal | 单步进入 |
| `<leader>do` | Normal | 单步跳出 |
| `<leader>dr` | Normal | 打开 REPL |
| `<leader>de` | Normal | 运行上次命令 |
| `<leader>ds` | Normal | 切换 REPL |
| `<leader>dx` | Normal | 关闭 REPL |
| `<F6>` | Normal | 运行上次调试 |
| `<leader>du` | Normal | 切换调试 UI |
| `\\s` | Normal | 评估表达式 |

#### 终端 (floaterm)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<F12>` | Normal | 切换浮动终端 |
| `<leader>ft` | Normal | 新建浮动终端 |
| `<leader>k` | Normal | 关闭浮动终端 |

#### 搜索与导航 (snacks.nvim)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>f` | Normal | 查找文件 |
| `<leader>/` | Normal | 全局搜索 (Grep) |
| `<leader>b` | Normal | 搜索缓冲区 |
| `<leader>rt` | Normal | 最近文件 |
| `<leader>qf` | Normal | QuickFix 窗口 |
| `<leader>dg` | Normal | 搜索诊断 |
| `<leader>ud` | Normal | 撤销历史 |
| `<leader>sb` | Normal | LSP 符号 |
| `<leader>sB` | Normal | LSP 工作区符号 |
| `<M-k>` | Normal | 搜索快捷键 |
| `<c-f>` | Normal | Ripgrep 搜索 |

#### Git 集成 (snacks.nvim)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `git` | Normal | 打开 Lazygit |
| `<leader>gl` | Normal | Git 日志 |
| `<leader>gb` | Normal | Git 分支 |

#### LSP 导航 (snacks.nvim)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>gd` | Normal | 跳转到定义 |
| `<leader>gD` | Normal | 跳转到声明 |
| `<leader>gr` | Normal | 查找引用 |
| `<leader>gi` | Normal | 跳转到实现 |
| `<leader>gy` | Normal | 跳转到类型定义 |

#### 其他工具 (snacks.nvim)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>nf` | Normal | 通知历史 |
| `<leader>Z` | Normal | 禅模式 |

#### 任务运行
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `\\t` | Normal | 选择并运行任务 |

#### 项目管理
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>pr` | Normal | 打开项目列表 |

#### TODO 注释
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `]t` | Normal | 下一个 TODO 注释 |
| `[t` | Normal | 上一个 TODO 注释 |
| `<leader>xt` | Normal | TODO 列表 (Trouble) |
| `<leader>xT` | Normal | TODO/FIX/FIXME 列表 |
| `<leader>st` | Normal | 搜索 TODO |

#### 代码格式化
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>=` | Normal/Visual | 格式化代码 |

#### 代码检查
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>l` | Normal | 触发代码检查 |

#### 注释
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>/` | Normal/Visual | 切换行注释 |
| `<leader>?` | Normal/Visual | 切换块注释 |

#### 快速跳转 (Flash)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `s` | Normal/Visual/Operator | Flash 跳转 |
| `S` | Normal/Visual/Operator | Flash Treesitter |
| `r` | Operator | 远程 Flash |
| `R` | Visual/Operator | Treesitter 搜索 |
| `<c-s>` | Insert | 切换 Flash 搜索 |

#### Which-key 帮助
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>?` | Normal | 显示本地快捷键 |

**Which-key 功能特性：**
- 🎨 **现代化界面设计** - 使用 modern 预设和图标
- 📋 **智能分组显示** - 按功能逻辑分组所有快捷键
- 🔍 **详细功能说明** - 每个快捷键都有清晰的中文描述
- ⚡ **即时帮助提示** - 按下 leader 键后自动显示可用选项
- 🎯 **图标化标识** - 为每个功能组和快捷键配置了相应图标

**主要功能分组：**
- `<leader>f` - 📁 文件操作 (查找、最近文件、终端)
- `<leader>b` - 📋 缓冲区管理 (切换、固定、删除)
- `<leader>s` - 🔍 搜索功能 (全局搜索、符号搜索)
- `<leader>g` - 🌿 Git 操作 (日志、分支、跳转)
- `<leader>d` - 🐛 调试功能 (断点、单步、REPL)
- `<leader>t` - 🧪 测试和终端 (运行测试、终端管理)
- `<leader>o` - ⚙️ 任务管理 (Overseer 任务运行)
- `<leader>c` - 💻 代码操作 (代码动作、快速修复)
- `<leader>w` - 🪟 工作区管理 (文件夹操作)

#### Neovide 特定功能
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<F10>` | Normal/Insert | 切换透明度 |
| `<F11>` | Normal | 切换全屏 |

#### 测试 (Neotest)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>tt` | Normal | 运行当前文件测试 |
| `<leader>tT` | Normal | 运行所有测试文件 |
| `<leader>tr` | Normal | 运行最近的测试 |
| `<leader>tl` | Normal | 运行上次测试 |
| `<leader>ts` | Normal | 切换测试摘要 |
| `<leader>to` | Normal | 显示测试输出 |
| `<leader>tO` | Normal | 显示测试输出面板 |
| `<leader>tw` | Normal | 观察模式 |

#### 任务管理 (Overseer)
| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>ow` | Normal | 切换任务列表 |
| `<leader>oo` | Normal | 运行任务 |
| `<leader>oq` | Normal | 快速操作最近任务 |
| `<leader>oi` | Normal | Overseer 信息 |
| `<leader>ob` | Normal | 任务构建器 |
| `<leader>ot` | Normal | 任务操作 |
| `<leader>oc` | Normal | 清除缓存 |

## 配置结构

```
~/.config/nvim/
├── init.lua                  # 主配置文件
├── lua/
│   ├── config/
│   │   └── lazy.lua         # lazy.nvim 配置
│   ├── core/
│   │   ├── autocmds.lua     # 自动命令
│   │   ├── keymaps.lua      # 键盘映射
│   │   └── options.lua      # Neovim 选项
│   └── plugins/             # 插件配置
│       ├── ai.lua           # AI 助手 (Copilot)
│       ├── cmp.lua          # 自动补全
│       ├── dap.lua          # 调试器
│       ├── format.lua       # 代码格式化
│       ├── lsp-config.lua   # LSP 配置
│       ├── mason.lua        # 包管理器
│       ├── ui.lua           # UI 组件
│       └── ...              # 其他插件
```

## 主要插件

### 核心插件管理
- **[lazy.nvim](https://github.com/folke/lazy.nvim)**: 现代化的插件管理器，支持延迟加载
- **[mason.nvim](https://github.com/williamboman/mason.nvim)**: LSP 服务器、DAP 服务器、格式化工具管理器 (已禁用，改用 COC)

### 语言支持和补全
- **[coc.nvim](https://github.com/neoclide/coc.nvim)**: 强大的 LSP 客户端，提供完整的 IDE 体验
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)**: 自动补全框架
- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)**: 代码片段引擎
- **[friendly-snippets](https://github.com/rafamadriz/friendly-snippets)**: 常用代码片段集合
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: 语法高亮和代码解析

### 界面和导航
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)**: 模糊搜索和文件浏览
- **[snacks.nvim](https://github.com/folke/snacks.nvim)**: 现代化的通知和界面组件
- **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)**: 文件浏览器
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)**: 标签页和缓冲区管理
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: 状态栏
- **[aerial.nvim](https://github.com/stevearc/aerial.nvim)**: 符号和大纲视图
- **[scope.nvim](https://github.com/tiagovla/scope.nvim)**: 标签页作用域管理
- **[which-key.nvim](https://github.com/folke/which-key.nvim)**: 快捷键提示

### 编辑增强
- **[nvim-surround](https://github.com/kylechui/nvim-surround)**: 环绕字符操作
- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)**: 自动配对括号
- **[flash.nvim](https://github.com/folke/flash.nvim)**: 快速跳转
- **[nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)**: 代码折叠增强
- **[pretty-fold.nvim](https://github.com/anuvyklack/pretty-fold.nvim)**: 美化代码折叠
- **[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)**: 缩进线显示

### 终端和命令工具
- **[vim-floaterm](https://github.com/voldikss/vim-floaterm)**: 浮动终端
- **[fzf-lua](https://github.com/ibhagwan/fzf-lua)**: FZF 集成

### 数据库工具
- **[nvim-dbee](https://github.com/kndndrj/nvim-dbee)**: 现代数据库客户端
- **[vim-dadbod](https://github.com/tpope/vim-dadbod)**: 数据库操作
- **[vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui)**: 数据库界面
- **[vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion)**: 数据库补全

### 特殊格式支持
- **[typst-preview.nvim](https://github.com/chomosuke/typst-preview.nvim)**: Typst 文档预览
- **[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)**: Markdown 预览
- **[nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)**: 颜色预览

### 主题和外观
- **[tokyonight.nvim](https://github.com/folke/tokyonight.nvim)**: Tokyo Night 主题
- **[mini.icons](https://github.com/echasnovski/mini.icons)**: 图标支持
- **[nvim-notify](https://github.com/rcarriga/nvim-notify)**: 通知系统
- **[noice.nvim](https://github.com/folke/noice.nvim)**: 命令行和消息界面

### AI 和智能助手
- **[copilot.lua](https://github.com/zbirenbaum/copilot.lua)**: GitHub Copilot 集成
- **[CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim)**: Copilot 对话界面
- **[render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)**: Markdown 渲染

### 调试和测试工具
- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)**: 调试器适配协议，支持多种语言
- **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)**: 调试器图形界面
- **[nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)**: Python 调试支持
- **[nvim-dap-go](https://github.com/leoluz/nvim-dap-go)**: Go 调试支持
- **[nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text)**: 调试时显示变量值
- **[neotest](https://github.com/nvim-neotest/neotest)**: 测试框架，支持多种测试工具
- **[vimspector-dap](https://github.com/DoDoENT/vimspector-dap)**: Vimspector 与 DAP 集成

### 代码质量和格式化
- **[conform.nvim](https://github.com/stevearc/conform.nvim)**: 代码格式化 (已禁用，改用 COC)
- **[nvim-lint](https://github.com/mfussenegger/nvim-lint)**: 代码检查和 Lint
- **[Comment.nvim](https://github.com/numToStr/Comment.nvim)**: 智能注释
- **[todo-comments.nvim](https://github.com/folke/todo-comments.nvim)**: TODO 注释高亮

### 版本控制
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)**: Git 集成和标记
- **[neogit](https://github.com/TimUntersberger/neogit)**: Git 客户端 (可选)

### 任务和项目管理
- **[overseer.nvim](https://github.com/stevearc/overseer.nvim)**: 任务运行器
- **[project.nvim](https://github.com/ahmedkhalf/project.nvim)**: 项目管理
- **[asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)**: 异步任务系统
- **[asyncrun.vim](https://github.com/skywind3000/asyncrun.vim)**: 异步命令执行

### 搜索和导航
- **[snacks.nvim](https://github.com/folke/snacks.nvim)**: 模糊搜索和各种实用工具
- **[project.nvim](https://github.com/ahmedkhalf/project.nvim)**: 项目管理
- **[todo-comments.nvim](https://github.com/folke/todo-comments.nvim)**: TODO 注释高亮
- **[trouble.nvim](https://github.com/folke/trouble.nvim)**: 诊断和引用列表

### 终端和任务
- **[vim-floaterm](https://github.com/voldikss/vim-floaterm)**: 浮动终端
- **[asynctasks.vim](https://github.com/skywind3000/asynctasks.vim)**: 异步任务
- **[asyncrun.vim](https://github.com/skywind3000/asyncrun.vim)**: 异步运行

### 语言特定
- **[render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)**: Markdown 渲染
- **[typst-preview.nvim](https://github.com/chomosuke/typst-preview.nvim)**: Typst 预览

## 自定义配置

### 修改 Leader 键
在 `lua/config/lazy.lua` 和 `lua/core/options.lua` 中修改：
```lua
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"
```

### 添加新的快捷键
在 `lua/core/keymaps.lua` 中添加：
```lua
local keymap = vim.keymap.set
keymap("n", "<your-key>", "<your-command>", { desc = "Description" })
```

### 主题配置
在 `lua/plugins/ui.lua` 中修改 tokyonight 配置：
```lua
opts = {
    style = "night", -- storm, moon, night, day
    transparent = true,
    -- 其他选项...
},
```

## 🔧 维护和管理

本配置提供了几个内置的维护命令来帮助管理配置：

### 维护命令

```vim
:ConfigMaintenance    " 执行完整维护（清理缓存 + 更新插件 + 健康检查）
:ConfigClean         " 清理插件缓存
:ConfigUpdate        " 更新所有插件
:ConfigCheck         " 运行健康检查
```

### 定期维护建议

建议定期执行以下操作来保持配置的最佳状态：

1. **每周运行一次完整维护**：
   ```vim
   :ConfigMaintenance
   ```

2. **遇到问题时清理缓存**：
   ```vim
   :ConfigClean
   ```

3. **定期检查配置健康状态**：
   ```vim
   :ConfigCheck
   ```

### COC 扩展管理

本配置包含自定义的 COC 扩展管理器，提供便捷的扩展管理功能：

```vim
:CocExtensionManager install    " 安装推荐的 COC 扩展
:CocExtensionManager status     " 查看扩展安装状态  
:CocExtensionManager update     " 检查并更新所有扩展
:CocExtensionManager cleanup    " 清理不需要的扩展
```

**推荐扩展包括：**
- 核心语言支持：JSON、HTML、CSS、YAML、XML
- JavaScript/TypeScript：tsserver、eslint、prettier
- Python：pyright、python 工具集
- Web 开发：emmet、stylelint、tailwindcss
- 开发工具：git、docker、snippets、marketplace
- AI 工具：copilot

### 工具模块使用

`utils/` 目录包含以下实用工具：

1. **维护工具** (`maintenance.lua`) - 自动加载，提供维护命令
2. **COC 管理器** (`coc-manager.lua`) - COC 扩展管理
3. **图标定义** (`icons.lua`) - 统一的图标配置
4. **DAP 工具** (`dap.lua`) - 调试器辅助功能

这些工具在配置启动时自动初始化，无需手动加载。

## 常见问题和故障排除

### 插件问题

#### 插件未加载或更新失败
```vim
:Lazy sync          " 同步所有插件
:Lazy clean         " 清理未使用的插件
:Lazy update        " 更新所有插件
:Lazy profile       " 查看启动性能
```

#### COC 扩展问题
```vim
:CocInstall coc-json coc-html coc-css    " 手动安装扩展
:CocUpdate                               " 更新所有扩展
:CocList extensions                      " 查看已安装扩展
:CocRestart                             " 重启 COC 服务
```

### 语言服务器问题

#### 检查 LSP 状态
```vim
:checkhealth coc        " 检查 COC 健康状态
:CocInfo               " 查看 COC 详细信息
:CocCommand            " 执行 COC 命令
```

#### 调试器问题
```vim
:checkhealth nvim-dap  " 检查 DAP 配置
:lua require('dap').list_breakpoints()  " 列出断点
```

### 性能优化

#### 启动时间优化
```vim
:Lazy profile          " 查看插件加载时间
:startuptime          " 分析启动时间
```

#### 内存使用优化
```vim
:checkhealth          " 全面健康检查
:lua collectgarbage() " 手动垃圾回收
```

### 常见错误解决

#### 找不到命令行工具
1. 确保工具已正确安装在 PATH 中
2. 重启终端和 Neovim
3. 检查 `~/.bashrc` 或 `~/.zshrc` 配置

#### 字体图标显示问题
1. 安装 Nerd Font 字体
2. 设置终端使用 Nerd Font
3. 重启终端应用程序

#### 调试器连接失败
1. 检查调试端口是否被占用
2. 确认目标程序正在运行
3. 验证调试器二进制文件路径

#### 剪切板不工作
本配置包含智能跨平台剪切板检测，会自动选择最佳的剪切板工具：

**Windows:**
- 自动使用 `win32yank.exe` (推荐) 或 `clip.exe`
- 如果安装脚本未成功安装，手动安装：
  ```powershell
  winget install equalsraf.win32yank
  ```

**Linux:**
- X11 环境：`xclip` 或 `xsel`
- Wayland 环境：`wl-clipboard`
- 安装命令：
  ```bash
  # Ubuntu/Debian
  sudo apt install xclip wl-clipboard
  
  # Arch Linux
  sudo pacman -S xclip wl-clipboard
  
  # CentOS/RHEL
  sudo yum install xclip wl-clipboard
  ```

**macOS:**
- 自动使用内置的 `pbcopy` 和 `pbpaste`

**Termux (Android):**
- 使用 `termux-clipboard-set` 和 `termux-clipboard-get`
- 安装：`pkg install termux-api`

**SSH/远程环境:**
- 自动使用 OSC 52 协议进行剪切板同步
- 需要终端支持 OSC 52（大多数现代终端都支持）

如果剪切板仍不工作，检查：
```vim
:checkhealth          " 查看剪切板状态
:echo has('clipboard') " 应该返回 1
:echo g.clipboard      " 查看当前剪切板配置
```

### 配置定制

#### 添加新的语言支持
1. 在 `lua/plugins/coc.lua` 中添加 COC 扩展
2. 在 `lua/plugins/dap.lua` 中配置调试器
3. 在 `lua/plugins/treesitter.lua` 中添加语法解析器

#### 修改键位映射
编辑 `lua/core/keymaps.lua` 文件来自定义快捷键。

#### 更换主题
在 `lua/plugins/ui.lua` 中修改 `tokyonight` 配置或更换其他主题。

## 更新日志

### 版本特性
- **v2.0**: 迁移到 COC.nvim，提升稳定性
- **v1.5**: 完整的多语言调试支持
- **v1.0**: 基础配置和插件集成

## 贡献指南

我们欢迎社区贡献来改进这个配置！

### 如何贡献
1. Fork 此仓库
2. 创建功能分支 (`git checkout -b feature/new-feature`)
3. 提交更改 (`git commit -m 'Add new feature'`)
4. 推送分支 (`git push origin feature/new-feature`)
5. 创建 Pull Request

### 贡献类型
- 🐛 Bug 修复
- ✨ 新功能添加
- 📚 文档改进
- 🎨 代码风格优化
- ⚡ 性能优化
- 🔧 配置改进

### 开发指南
- 遵循现有代码风格
- 添加适当的注释
- 更新相关文档
- 测试新功能的兼容性

## 致谢

感谢以下项目和开发者：
- Neovim 开发团队
- lazy.nvim 插件管理器
- 所有插件作者
- 社区贡献者

## 许可证

MIT License

Copyright (c) 2024 dascard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.