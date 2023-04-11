# 🤖 STM LSP
Patch [`clangd`](https://clangd.llvm.org/) LSP for STM32CubeIDE projects. Say goodbye to unresolved
includes and unknown types in your embedded projects.

## ✨ Features
* Patch STM projects in a single command
* Get fully working LSP for projects generated on STM32CubeIDE
* Works with [`clangd`](https://clangd.llvm.org/)

## ⚡️ Requirements
* [`make`](https://www.gnu.org/software/make/manual/make.html)
* [`compiledb`](https://github.com/nickdiego/compiledb) (install via `pip`)
* Only works on Linux and macOS for now

## 📦 Installation
Can be installed with any package manager.

### [Lazy](https://github.com/folke/lazy.nvim)
```lua
-- Surround feature
{
    "my_account/my_repo",
    config = function()
        require("stm_lsp_nvim").setup({
        -- Custom configuration, or leave empty for default config
        })
    end
},
```

### [Packer](https://github.com/wbthomason/packer.nvim)
```lua
-- Lua
use {
  "my_account/my_repo",
  config = function()
    require("stm_lsp_nvim").setup {
        -- Custom configuration, or leave empty for default config
    }
  end
}
```

## ⚙️ Configuration
The plugin comes with the following default config:
```lua
local defaults = {
    input_path = "Debug/compile_commands.json", -- Path to input file
    output_path = "build/compile_commands.json", -- Path to ouput file
    excludes = { -- List of patterns to exclude from file
        "fcyclomatic",
    },
}
```

## 🚀 Usage
Just launch [`neovim`](https://github.com/neovim/neovim) in a STM project root directory and run the `:StmLspPatch`
command, and **voilà**, your [`clangd`](https://clangd.llvm.org/) LSP should now be able to find all the
header files, types and functions definitions, etc.

## 🤔 Under the hood
The way this plugin works is quite simple. STM projects use Makefile to
indicate the compiler, the arguments, and most importantly, all the 
include paths to header files.

[`clangd`](https://clangd.llvm.org/) cannot use the Makefile directly to
resolve includes, and need a special JSON file named `compile_commands.json`
which holds all the information held by the Makefile.

A Makefile does not generate such a file on its own (contrary to CMake). So
to generate one, we use the wonderful
[`compiledb`](https://github.com/nickdiego/compiledb) python package.

Once the file is generated, we need to get rid of a few lines to avoid
LSP complaints. STM uses a modified version of `arm-none-eabi-gcc`
with custom arguments, such as `-fcyclomatic-complexity`. This option is of
course not recognised by [`clangd`](https://clangd.llvm.org/) which throws an error. We therefore filter
all the lines containing it.

Finally, [`clangd`](https://clangd.llvm.org/) only looks for the `compile_commands.json` files in
precise locations. This is why we place the modified version in the 
`build/` subdirectory (not used by STM32CubeIDE).

## 🛠️ Issues and contribution

This is my first public (and, hopefully, useful) repo on GitHub, and also my
first time writing a plugin for Neovim. So, you may have some issues trying
to use it, or find gross mistakes in the code.

* If you have a problem installing / using the plugin, don't hesitate
to open a GitHub issue. I will to my best to help you.
* If you have an idea on how to improve the plugin or can think of a way
to optimise / correct it, please feel free to open a pull request.
