# Neovim 配置

这是一个基于 lazy.nvim 的 Neovim 配置，专为提高开发效率而设计。

## 特性

- 🚀 使用 [lazy.nvim](https://github.com/folke/lazy.nvim) 进行插件管理
- 🎨 使用 Tokyo Night 主题
- 🔧 完整的 LSP 支持 (通过 mason.nvim)
- 🐛 调试支持 (DAP)
- 📁 文件管理器 (nvim-tree)
- 🔍 模糊搜索 (snacks.nvim)
- 💡 智能补全 (nvim-cmp + Copilot)
- ⚡ 快速导航和编辑工具

## 安装

1. 备份现有配置：
```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.local/state/nvim ~/.local/state/nvim.backup
```

2. 克隆此配置：
```bash
git clone https://github.com/your-username/nvim_config ~/.config/nvim
```

3. 启动 Neovim：
```bash
nvim
```

插件将自动安装。

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

### 核心插件
- **[lazy.nvim](https://github.com/folke/lazy.nvim)**: 现代化的插件管理器
- **[mason.nvim](https://github.com/williamboman/mason.nvim)**: LSP 服务器、DAP 服务器、格式化工具管理器
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: LSP 配置
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)**: 自动补全框架

### UI 插件
- **[tokyonight.nvim](https://github.com/folke/tokyonight.nvim)**: Tokyo Night 主题
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: 状态栏
- **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)**: 文件管理器
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)**: 缓冲区标签页
- **[which-key.nvim](https://github.com/folke/which-key.nvim)**: 快捷键提示
- **[noice.nvim](https://github.com/folke/noice.nvim)**: 增强 UI 体验
- **[mini.icons](https://github.com/echasnovski/mini.icons)**: 图标支持

### 编辑增强
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: 语法高亮和代码解析
- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)**: 自动配对括号
- **[nvim-surround](https://github.com/kylechui/nvim-surround)**: 环绕操作
- **[flash.nvim](https://github.com/folke/flash.nvim)**: 快速跳转
- **[comment.nvim](https://github.com/numToStr/Comment.nvim)**: 注释工具
- **[nvim-colorizer.lua](https://github.com/catgoose/nvim-colorizer.lua)**: 颜色高亮
- **[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)**: 缩进线
- **[nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)**: 高级代码折叠

### 开发工具
- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)**: 调试器适配协议
- **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)**: 调试器界面
- **[conform.nvim](https://github.com/stevearc/conform.nvim)**: 代码格式化
- **[nvim-lint](https://github.com/mfussenegger/nvim-lint)**: 代码检查
- **[copilot.lua](https://github.com/zbirenbaum/copilot.lua)**: GitHub Copilot 集成
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)**: Git 集成
- **[overseer.nvim](https://github.com/stevearc/overseer.nvim)**: 任务运行器
- **[neotest](https://github.com/nvim-neotest/neotest)**: 测试框架

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

## 故障排除

### 插件未加载
```bash
:Lazy sync
```

### LSP 服务器问题
```bash
:Mason
:LspInfo
```

### 检查健康状态
```bash
:checkhealth
```

## 贡献

欢迎提交 Issues 和 Pull Requests 来改进这个配置！

## 许可证

MIT License