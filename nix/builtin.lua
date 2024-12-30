vim.opt.completeopt = "menu,menuone,noselect"

local cmp = require("cmp")
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "buffer" },
		{ name = "neorg" },
	}),
})

require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
	},
})

require("neorg").setup({
	load = {
		["core.defaults"] = {},
		["core.completion"] = {
			config = {
				engine = "nvim-cmp",
			},
		},
		["core.integrations.nvim-cmp"] = {},
		["core.dirman"] = {
			config = {
				workspaces = {
					tests = "tests",
				},
				index = "index.norg",
				default_workspace = "tests",
			},
		},
	},
})
