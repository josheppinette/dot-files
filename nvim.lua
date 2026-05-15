-- [[ Globals ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Options ]]

vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum,fuzzy"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 5
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- [[ Basic Keymaps ]]

vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ LSP Keymaps ]]
--
-- Uses Neovim's built-in LSP mappings. See more details with `:h lsp-defaults`.
--
--   grn  	rename
--   grr  	references
--   gra  	code action
--   gri  	implementation
--   gO   	document symbols
--   K    	hover
--   CTRL-S	signature help

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- [[ Install Plugin Manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.opt.rtp:prepend(lazypath)

-- [[ Filetype Overrides ]]

vim.filetype.add({
	extension = {
		rec = "rec",
		bean = "beancount",
	},
	filename = {
		["user-data"] = "yaml",
		["meta-data"] = "yaml",
	},
})

-- [[ User Commands ]]
vim.api.nvim_create_user_command("ConformDisable", function()
	vim.b.conform_disable = true
end, { desc = "Disable autoformat-on-save" })
vim.api.nvim_create_user_command("ConformEnable", function()
	vim.b.conform_disable = false
end, { desc = "Re-enable autoformat-on-save" })

-- [[ Configure & Install Plugins ]]

require("lazy").setup({

	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- Markdown
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			local servers = {
				beancount = {
					init_options = { journal_file = vim.fn.getcwd() .. "/main.bean" },
				},
				jdtls = {
					handlers = { ["$/progress"] = function() end },
				},
				clangd = {},
				gopls = {},
				hls = { filetypes = { "haskell", "lhaskell", "cabal" } },
				nixd = {},
				kotlin_language_server = {},
				phpactor = {},
				taplo = {},
				lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
				pylsp = {
					settings = {
						pylsp = {
							plugins = {
								mccabe = { enabled = false },
								pycodestyle = { enabled = false },
								pyflakes = { enabled = false },
								ruff = { enabled = true },
								mypy = { enabled = true },
							},
						},
					},
				},
				ts_ls = { settings = { completions = { completeFunctionCalls = true } } },
			}

			for server, config in pairs(servers) do
				vim.lsp.config(server, config)
				vim.lsp.enable(server)
			end
		end,
	},

	{ -- Auto format
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			local prettier = { "prettierd", "prettier", stop_after_first = true }
			require("conform").setup({
				format_on_save = function(n)
					if vim.b[n].conform_disable then
						return
					end
					return {
						timeout_ms = 1000,
						lsp_format = "fallback",
					}
				end,
				formatters_by_ft = {
					html = prettier,
					cabal = { "cabal_fmt" },
					lisp = { "cljfmt" },
					go = { "goimports", "gofmt", stop_after_first = true },
					java = { "google-java-format" },
					javascript = prettier,
					javascriptreact = prettier,
					json = prettier,
					lua = { "stylua" },
					php = { "php_cs_fixer" },
					kotlin = { "ktfmt" },
					markdown = prettier,
					python = function(bufnr)
						if require("conform").get_formatter_info("ruff_format", bufnr).available then
							return { "ruff_fix", "ruff_format" }
						else
							return { "isort", "black" }
						end
					end,
					sh = { "shfmt" },
					tex = { "tex-fmt" },
					typescript = prettier,
					typescriptreact = prettier,
					yaml = prettier,
				},
			})
		end,
	},

	{ -- Colorscheme
		"catppuccin/nvim",
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("catppuccin-mocha")
			vim.cmd.hi("Comment gui=none")
		end,
	},

	{ -- Status Line
		"nvim-lualine/lualine.nvim",
		opts = {
			sections = {
				lualine_b = { "diff", "diagnostics" },
				lualine_x = { "filetype" },
			},
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	{ -- Mini Plugins
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			require("mini.bracketed").setup()

			local pick = require("mini.pick")
			pick.setup()

			vim.keymap.set("n", "<leader>sf", pick.builtin.files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sg", pick.builtin.grep_live, { desc = "[S]earch [G]rep" })
			vim.keymap.set("n", "<leader>sb", pick.builtin.buffers, { desc = "[S]earch [B]uffers" })
			vim.keymap.set("n", "<leader>sh", pick.builtin.help, { desc = "[S]earch [H]elp" })

			local extra = require("mini.extra")
			extra.setup()

			vim.keymap.set("n", "<leader>sd", extra.pickers.diagnostic, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sk", extra.pickers.keymaps, { desc = "[S]earch [K]eymaps" })
		end,
	},

	{ -- GNU Recutils
		"zaid/vim-rec",
		ft = "rec",
	},

	{ -- Sort
		"sQVe/sort.nvim",
		opts = {
			mappings = {
				operator = "gs",
				textobject = false,
				motion = false,
			},
		},
	},

	{ -- Highlight, Edit, Navigate
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
		},
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 5, multiline_threshold = 1 } },
		},
	},

	{ -- Parentheses Inference
		"gpanders/nvim-parinfer",
		ft = "lisp",
	},
})
