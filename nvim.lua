-- [[ Globals ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- [[ Options ]]

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
vim.opt.foldmethod = "expr"
vim.opt.foldlevel = 99
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

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

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "user-data", "meta-data" },
	callback = function()
		vim.bo.filetype = "yaml"
	end,
})

-- [[ EXPAND 4 ]]
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "php" },
	command = "setlocal shiftwidth=4 softtabstop=4 expandtab",
})

-- [[ EXPAND 2 ]]
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"haskell",
		"phtml",
		"nix",
		"json",
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"c",
		"cpp",
		"markdown",
		"toml",
	},
	command = "setlocal shiftwidth=2 softtabstop=2 expandtab",
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

	{ -- Fuzzy Finder
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons" },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set(
				"n",
				"<leader>/",
				builtin.current_buffer_fuzzy_find,
				{ desc = "[/] Fuzzily search in current buffer" }
			)
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("LspAttach", { clear = true }),
				callback = function(attach_event)
					-- Mappings helper
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = attach_event.buf, desc = "LSP: " .. desc })
					end

					-- Apply mappings
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- When the cursor is still, similar references will be highlighted
					local client = vim.lsp.get_client_by_id(attach_event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local group = vim.api.nvim_create_augroup("Highlights", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = attach_event.buf,
							group = group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = attach_event.buf,
							group = group,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("LspDetach", { clear = true }),
							callback = function(detach_event)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "Highlights", buffer = detach_event.buf })
							end,
						})
					end
				end,
			})

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			-- You can find the list of all supported servers [here](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md). In a buffer, you can see the current LSP status with :LspInfo.
			local servers = {
				clangd = {},
				gopls = {},
				hls = {},
				nixd = {},
				phpactor = {},
				taplo = {},
				lua_ls = { Lua = { diagnostics = { globals = { "vim" } } } },
				pylsp = {
					pylsp = {
						plugins = {
							mccabe = { enabled = false },
							pycodestyle = { enabled = false },
							pyflakes = { enabled = false },
							flake8 = { enabled = true },
						},
						configurationSources = { "flake8" },
					},
				},
				ts_ls = { completions = { completeFunctionCalls = true } },
			}

			for server, settings in pairs(servers) do
				local configuration = {
					settings = settings,
					capabilities = capabilities,
				}
				require("lspconfig")[server].setup(configuration)
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
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end,
				formatters_by_ft = {
					html = prettier,
					javascript = prettier,
					javascriptreact = prettier,
					json = prettier,
					lua = { "stylua" },
					php = { "php_cs_fixer" },
					markdown = prettier,
					python = { "isort", "black" },
					sh = { "shfmt" },
					typescript = prettier,
					typescriptreact = prettier,
				},
			})
		end,
	},

	{ -- Auto complete
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")

			cmp.setup({
				completion = { completeopt = "menu,menuone,noinsert" },
				performance = { max_view_entries = 5 },
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				formatting = {
					format = lspkind.cmp_format(),
				},
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),

					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					-- Manually trigger a completion from nvim-cmp.
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "buffer" },
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

	-- Todo Comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
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
		end,
	},

	{ -- Better Quick Fix
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		opts = {},
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
}, {})
