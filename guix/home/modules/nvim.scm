(define-module (home modules nvim)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:export (%my-nvim-service))

(define %my-nvim-service
  (simple-service
   'nvim-config
   home-files-service-type
   (list
    `(".config/nvim/init.lua"
      ,(plain-file
        "init.lua"
        "-- minimal nvim config
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = false
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
")))))
