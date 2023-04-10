" Title:        STM LSP nvim
" Description:  Patch stm generated projects to work with clangd LSP
" Last Change:  10 April 2023
" Maintainer:   Alex Schulster <https://github.com/alex-schulster>

" Make sure the plugin is loaded a single time
if exists("g:loaded_stm_lsp")
    finish
endif
let g:loaded_stm_lsp = 1

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 StmLspPatch lua require("stm_lsp_nvim").patch_lsp()
