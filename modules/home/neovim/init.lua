vim.loader.enable()

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
vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist()
end, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>o", function()
	vim.ui.open(vim.fn.expand("%:p"))
end, { desc = "[O]pen" })
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

-- [[ Plugins ]]
--
-- Plugins are installed by Nix (see `programs.neovim.plugins` in home.nix).

-- Colorscheme
vim.cmd.colorscheme("catppuccin-mocha")
vim.cmd.hi("Comment gui=none")

-- Git signs in the gutter
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

-- Status line
require("lualine").setup({
	sections = {
		lualine_b = { "diff", "diagnostics" },
		lualine_x = { "filetype" },
	},
})

-- LSP
require("fidget").setup({})

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
	rust_analyzer = {},
	kotlin_language_server = {},
	phpactor = {},
	taplo = {
		settings = {
			evenBetterToml = {
				schema = { enabled = false },
			},
		},
	},
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

-- Auto format
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
		ocaml = { "ocamlformat" },
		dune = { "format-dune-file" },
		python = function(bufnr)
			if require("conform").get_formatter_info("ruff_format", bufnr).available then
				return { "ruff_fix", "ruff_format" }
			else
				return { "isort", "black" }
			end
		end,
		rust = { "rustfmt" },
		scala = { "scalafmt" },
		sh = { "shfmt" },
		tex = { "tex-fmt" },
		typescript = prettier,
		typescriptreact = prettier,
		yaml = prettier,
	},
})

-- Mini
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

-- Sort
require("sort").setup({
	mappings = {
		operator = "gs",
		textobject = false,
		motion = false,
	},
})

-- Treesitter
vim.api.nvim_create_autocmd("FileType", {
	desc = "Enable treesitter highlighting and indentation",
	group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

require("treesitter-context").setup({ max_lines = 5, multiline_threshold = 1 })
