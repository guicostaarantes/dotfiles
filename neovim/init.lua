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
vim.opt.shell = 'fish'
vim.opt.updatetime = 1000
vim.opt.cursorline = false
vim.opt.termguicolors = true
vim.opt.listchars = 'tab:» ,extends:›,precedes:‹,nbsp:#';

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
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 1000
			vim.g.mapleader = ' '
			local set = vim.keymap.set
			-- jk to cancel insert mode
			set('i', 'jk', '<Esc>')
			set('t', 'jk', '<C-\\><C-n>')
			-- do not add to register with x, c or d
			set('n', 'x', '"_x')
			set('n', 'd', '"_d')
			set('n', 'D', 'd')
			set('n', 'c', '"_c')
			set('n', 'C', 'c')
			set('n', 'Y', '"+y')
			set('v', 'x', '"_x')
			set('v', 'd', '"_d')
			set('v', 'D', 'd')
			set('v', 'c', '"_c')
			set('v', 'C', 'c')
			set('v', 'Y', '"+y')
			-- first level keybindings
			set('n', '-', '<cmd>lua require("oil").open()<cr>', {
				silent = true,
				desc = 'Explore directory of current buffer',
			})
			-- which-key for maps that start with the leader key
			local which = require('which-key')
			which.setup {}
			which.register({
				['<leader>'] = {
					Q = { '<cmd>bd!<cr>', 'Quit buffer (discard unsaved changes)' },
					q = { '<cmd>w<cr><cmd>bd<cr>', 'Save and quit buffer' },
					e = { '<cmd>Oil .<cr>', 'Explore project directory' },
					r = { '<cmd>Telescope oldfiles<cr>', 'Open recent buffer' },
					t = { '<cmd>term<cr>', 'Open new terminal buffer' },
					y = { '<cmd>lua vim.lsp.buf.format()<cr>', 'Format document' },
					u = { '<cmd>lua vim.lsp.buf.references()<cr>', 'List references' },
					i = { '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol' },
					-- o = {},
					-- p = {},
					a = { '<cmd>wa<cr>', 'Save all buffers' },
					s = { '<cmd>w<cr>', 'Save buffer' },
					d = { '<cmd>lua vim.lsp.buf.definition()<cr>', 'Jump to definition' },
					f = { '<cmd>Telescope find_files<cr>', 'Search file in current directory' },
					g = { '<cmd>Telescope live_grep<cr>', 'Search file content in current directory' },
					h = { '<cmd>lua vim.lsp.buf.hover()<cr>', 'Show documentation' },
					j = { '<cmd>Gitsigns next_hunk<cr>', 'Jump to next git hunk' },
					k = { '<cmd>Gitsigns prev_hunk<cr>', 'Jump to previous git hunk' },
					-- l = {},
					z = { '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Show possible actions' },
					x = { '<cmd>lua vim.diagnostic.goto_prev()<cr>', 'Jump to previous diagnostic' },
					c = { '<cmd>lua vim.diagnostic.goto_next()<cr>', 'Jump to next diagnostic' },
					v = { '<cmd>Telescope diagnostics<cr>', 'List diagnostics' },
					b = { '<cmd>Telescope buffers<cr>', 'List buffers' },
					n = { '<cmd>G<cr><C-w>o', 'Open git client' },
					m = { '<cmd>Telescope resume<cr>', 'Back to Telescope panel' },
					w = {
						name = '+windows',
						s = { '<cmd>split<cr>', 'Create new window below' },
						v = { '<cmd>vsplit<cr>', 'Create new window to the right' },
						h = { '<C-w>h', 'Navigate to window in the left' },
						j = { '<C-w>j', 'Navigate to window below' },
						k = { '<C-w>k', 'Navigate to window above' },
						l = { '<C-w>l', 'Navigate to window in the right' },
						o = { '<C-w>o', 'Close all other windows' },
						c = { '<C-w>c', 'Close this window' },
					},
				},
			})
		end
	},

	{
		'neovim/nvim-lspconfig',
		init = function()
			local lsp = require('lspconfig')
			lsp.tsserver.setup {}
			lsp.eslint.setup {}
			lsp.jsonls.setup {}
			lsp.lua_ls.setup {}
			lsp.rust_analyzer.setup {}
			lsp.terraformls.setup {}
			lsp.tflint.setup {}
			lsp.yamlls.setup {}
			lsp.svelte.setup {}
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
						layout_config = {
							height = 30
						}
					},
					live_grep = {
						theme = 'ivy',
						layout_config = {
							height = 30
						}
					},
					oldfiles = {
						theme = 'ivy',
						layout_config = {
							height = 30
						}
					},
					buffers = {
						theme = 'ivy',
						layout_config = {
							height = 30
						},
						sort_mru = true,
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
					['<C-Space>'] = cmp.mapping.complete(),
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
		opts = {
			columns = {
				'icon',
			},
			view_options = {
				show_hidden = true,
			},
		},
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},

	{
		'folke/flash.nvim',
		opts = {},
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
