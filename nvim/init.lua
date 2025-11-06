local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.signcolumn = 'yes'
vim.opt.hlsearch = false
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.mouse = ''
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.scrolloff = 12
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.shell = vim.fn.has('win32') == 1 and 'powershell.exe' or 'zsh'
vim.opt.updatetime = 1000
vim.opt.cursorline = false
vim.opt.termguicolors = true
vim.diagnostic.config({
	virtual_text = false,
})

function NewTerminal()
	vim.ui.input({ prompt = 'Terminal name: ' }, function(name)
		if name == nil then return end
		vim.api.nvim_command("term")
		local terminal_name = name == '' and 'zsh' or string.format("%s.zsh", name)
		vim.api.nvim_command(string.format("fi %s", terminal_name))
		vim.opt_local.number = true
		vim.opt_local.relativenumber = true
		vim.api.nvim_command("startinsert")
	end)
end

function ClearTerminal()
	vim.opt_local.scrollback = 1
	vim.api.nvim_command("startinsert")
	vim.api.nvim_feedkeys("", 't', false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<cr>', true, false, true), 't', true)
	vim.api.nvim_feedkeys("clear", 't', false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<cr>', true, false, true), 't', true)
	vim.opt_local.scrollback = 10000
end

function ToggleMouse()
  if vim.o.mouse == '' then
    vim.opt.mouse = 'a'
    print("Mouse mode enabled")
  else
    vim.opt.mouse = ''
    print("Mouse mode disabled")
  end
end

require('lazy').setup({

	{
		'navarasu/onedark.nvim',
		opts = {
			style = 'darker',
			transparent = true
		},
		init = function()
			local onedark = require('onedark')
			onedark.load()
		end
	},

	{
		'folke/which-key.nvim',
		dependencies = {
			{ 'echasnovski/mini.icons', version = false },
			'nvim-tree/nvim-web-devicons',
		},
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 1000
			vim.g.mapleader = ' '
			local set = vim.keymap.set
			-- map escape in terminal mode to move into normal mode
			set('t', '<Esc>', '<C-\\><C-n>')
			-- do not add to register with x, c or d
			set('n', 'x', '"_x')
			set('n', 'd', '"_d')
			set('n', 'D', 'd')
			set('n', 'c', '"_c')
			set('n', 'C', 'c')
			set('v', 'x', '"_x')
			set('v', 'd', '"_d')
			set('v', 'D', 'd')
			set('v', 'c', '"_c')
			set('v', 'C', 'c')
			set('n', 'Y', '"+y')
			set('v', 'Y', '"+y')
			-- first level keybindings
			set('n', '-', '<cmd>lua require("oil").open()<cr>', {
				silent = true,
				desc = 'Explore directory of current buffer',
			})
			-- which-key for maps that start with the leader key
			local which = require('which-key')
			which.setup {}
			which.add(
				{
					{ "<leader>Q", "<cmd>bd!<cr>", desc = "Quit buffer (discard unsaved changes)" },
					{ "<leader>T", "<cmd>lua ClearTerminal()<cr>", desc = "Clear current terminal" },
					{ "<leader>a", "<cmd>wa<cr>", desc = "Save all buffers" },
					{ "<leader>b", "<cmd>Telescope buffers<cr>", desc = "List buffers" },
					{ "<leader>c", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Jump to next diagnostic" },
					{ "<leader>d", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Jump to definition" },
					{ "<leader>e", "<cmd>Oil .<cr>", desc = "Explore current directory" },
					{ "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Search file in current directory" },
					{ "<leader>g", "<cmd>Telescope live_grep<cr>", desc = "Search file content in current directory" },
					{ "<leader>h", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Show documentation" },
					{ "<leader>i", "<cmd>Telescope oldfiles<cr>", desc = "Open recent buffer list" },
					{ "<leader>j", "<cmd>Gitsigns prev_hunk<cr>", desc = "Jump to previous git hunk" },
					{ "<leader>k", "<cmd>lua ToggleMouse()<cr>", desc = "Turn mouse mode on/off" },
					{ "<leader>l", "<cmd>Gitsigns next_hunk<cr>", desc = "Jump to next git hunk" },
					{ "<leader>m", "<cmd>Telescope resume<cr>", desc = "Back to Telescope panel" },
					{ "<leader>n", "<cmd>G<cr><C-w>o", desc = "Open git client" },
					{ "<leader>p", "<cmd>pw<cr>", desc = "Check current directory" },
					{ "<leader>q", "<cmd>w<cr><cmd>bd<cr>", desc = "Save and quit buffer" },
					{ "<leader>r", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename symbol" },
					{ "<leader>s", "<cmd>w<cr>", desc = "Save buffer" },
					{ "<leader>t", "<cmd>lua NewTerminal()<cr>", desc = "Open new terminal buffer" },
					{ "<leader>u", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "List references" },
					{ "<leader>v", require("lsp_lines").toggle, desc = "Toggle diagnostic preview" },
					{ "<leader>w", group = "windows" },
					{ "<leader>wc", "<C-w>c", desc = "Close this window" },
					{ "<leader>wn", "<C-w>h", desc = "Navigate to window in the left" },
					{ "<leader>we", "<C-w>j", desc = "Navigate to window below" },
					{ "<leader>wi", "<C-w>k", desc = "Navigate to window above" },
					{ "<leader>wo", "<C-w>l", desc = "Navigate to window in the right" },
					{ "<leader>wa", "<C-w>o", desc = "Close all other windows" },
					{ "<leader>ws", "<cmd>split<cr>", desc = "Create new window below" },
					{ "<leader>wv", "<cmd>vsplit<cr>", desc = "Create new window to the right" },
					{ "<leader>x", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Jump to previous diagnostic" },
					{ "<leader>y", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format document" },
					{ "<leader>z", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Show possible actions" },
				})
		end
	},

	{
		'neovim/nvim-lspconfig',
		init = function()
			vim.lsp.config("gopls", {})
			vim.lsp.config("jsonls", {})
			vim.lsp.config("lemminx", {})
			vim.lsp.config("lua_ls", {})
			vim.lsp.config("pylsp", {})
			vim.lsp.config("rust_analyzer", {})
			vim.lsp.config("svelte", {})
			vim.lsp.config("terraformls", {})
			vim.lsp.config("tflint", {})
			vim.lsp.config("ts_ls", {})
			vim.lsp.config("yamlls", {})
		end
	},

	{
		'nvim-treesitter/nvim-treesitter',
		dependencies = {
			'nvim-treesitter/nvim-treesitter-textobjects',
		},
		build = ':TSUpdate',
		opts = {
			ensure_installed = {
				'bash',
				'go',
				'hcl',
				'javascript',
				'json',
				'lua',
				'rust',
				'svelte',
				'tsx',
				'typescript',
				'vim',
				'vimdoc',
				'yaml',
			},
		}
	},

	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		init = function()
			local telescope = require('telescope')
			local actions = require('telescope.actions')
			telescope.setup {
				pickers = {
					find_files = {
						theme = 'ivy',
						previewer = false,
						layout_config = {
							height = 30
						}
					},
					live_grep = {
						theme = 'ivy',
						previewer = false,
						layout_config = {
							height = 30
						}
					},
					oldfiles = {
						theme = 'ivy',
						previewer = false,
						layout_config = {
							height = 30
						}
					},
					buffers = {
						theme = 'ivy',
						previewer = false,
						layout_config = {
							height = 30
						},
						sort_mru = true,
						ignore_current_buffer = true,
						on_complete = { function() vim.cmd "stopinsert" end },
						mappings = {
							n = {
								q = actions.delete_buffer
							}
						},
					},
				},
			}
		end
	},

	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'L3MON4D3/LuaSnip',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
		},
		init = function()
			local luasnip = require('luasnip')
			local cmp = require('cmp')
			cmp.setup {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end
				},
				mapping = cmp.mapping.preset.insert {
					['<C-x>'] = cmp.mapping.complete(),
					['<Return>'] = cmp.mapping.confirm {
						behavior = cmp.ConfirmBehavior.Replace,
						select = true
					},
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				},
				sources = cmp.config.sources {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'buffer' }
				}
			}
		end
	},

	{
		'stevearc/conform.nvim',
		formatters_by_ft = {
			lua = { "stylua" },
			rust = { "rustfmt", lsp_format = "fallback" },
			javascript = { "prettier", "npx prettier", stop_after_first = true },
		},
	},

	{
		'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
		config = function()
			require("lsp_lines").setup()
		end
	},

	{
		'nvim-lualine/lualine.nvim',
		opts = {
			options = {
				icons_enabled = true,
			},
			sections = {
				lualine_a = { 'mode' },
				lualine_b = { 'branch' },
				lualine_c = { { 'filename', path = 1 } },
				lualine_x = { 'diagnostics' },
				lualine_y = {},
				lualine_z = {}
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { 'filename', path = 1 } },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {}
			}
		}
	},

	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		opts = {},
	},

	{
		'stevearc/oil.nvim',
		dependencies = {
			{ 'echasnovski/mini.icons', version = false },
			'nvim-tree/nvim-web-devicons',
		},
		opts = {
			columns = {
				'icon',
			},
			view_options = {
				show_hidden = true,
			},
			use_default_keymaps = false,
			keymaps = {
				['g?'] = 'actions.show_help',
				['<CR>'] = 'actions.select',
				['<C-l>'] = 'actions.refresh',
				['-'] = 'actions.parent',
				['ga'] = 'actions.cd',
				['gx'] = 'actions.open_external',
				['g.'] = 'actions.toggle_hidden',
				['g\\'] = 'actions.toggle_trash',
			},
		},
	},

	{
		'folke/flash.nvim',
		opts = {
			labels = "tnseriaogmdhcxzplfuwyqbjvk",
		},
		keys = {
			{ 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
			{ 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
			{ '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
		}
	},

	{
		'numToStr/Comment.nvim',
		opts = {}
	},

	{
		'lewis6991/gitsigns.nvim',
		opts = {}
	},

	'tpope/vim-fugitive',

	'sheerun/vim-polyglot',
})
