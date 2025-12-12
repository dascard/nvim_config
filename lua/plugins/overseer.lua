return {
	"stevearc/overseer.nvim",
	cmd = {
		"OverseerOpen",
		"OverseerClose",
		"OverseerToggle",
		"OverseerSaveBundle",
		"OverseerLoadBundle",
		"OverseerDeleteBundle",
		"OverseerRunCmd",
		"OverseerRun",
		"OverseerInfo",
		"OverseerBuild",
		"OverseerQuickAction",
		"OverseerTaskAction",
		"OverseerClearCache",
	},
	opts = {
		enable = true,
		dap = false,
		task_list = {
			height = 15,
			bindings = {
				["<C-h>"] = false,
				["<C-j>"] = false,
				["<C-k>"] = false,
				["<C-l>"] = false,
			},
		},
		form = {
			win_opts = {
				winblend = 0,
			},
		},
		confirm = {
			win_opts = {
				winblend = 0,
			},
		},
		task_win = {
			win_opts = {
				winblend = 0,
			},
		},
		templates = {
			"builtin",
			"user.script",
			"user.cmake",
			"user.cpp",
			"user.rust",
			"user.cargo",
		},
	},
  -- stylua: ignore
  keys = {
    { "<leader>ow", "<cmd>OverseerToggle<cr>",      desc = "Task list" },
    { "<leader>oo", "<cmd>OverseerRun<cr>",         desc = "Run task" },
    { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
    { "<leader>oi", "<cmd>OverseerInfo<cr>",        desc = "Overseer Info" },
    { "<leader>ob", "<cmd>OverseerBuild<cr>",       desc = "Task builder" },
    { "<leader>ot", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },
    { "<leader>oc", "<cmd>OverseerClearCache<cr>",  desc = "Clear cache" },
  },
}
