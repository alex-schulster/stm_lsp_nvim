-- Create module object
local M = {}

-- Check if a file exists
local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function M.patch_lsp()
    -- Generate the compile_commands.json file with compiledb
    local command = "cd " .. M.options.input_dir .. " && make clean > /dev/null && compiledb make -n all > /dev/null && cd .."

    -- Start job creating compile_commands.json file
    vim.fn.system(command)

    -- Check if os command went well
    if vim.v.shell_error ~= 0 then
        -- vim.api.nvim_command("Telescope")
        error(
        "Generation of compile_commands.json failed. "
        .. "Make sure you are in a stm Directory, and have `make` and "
        .. "`compiledb` installed on your machine"
        )
        return
    end

    -- Try to open generated file
    if not file_exists(M.options.input_path) then
        -- Failed to open, abort
        error("Could not open compile_commands.json file")
        return
    end

    -- Get all the lines which do not contain the -fcyclomatic option
    local filtered_text = ""
    for line in io.lines(M.options.input_path) do
        -- Init exclude line flag to false
        local exclude = false
        -- Search every pattern in the line
        for _, pattern in ipairs(M.options.excludes) do
            -- If one is true, set exclude flag to true and exit loop
            if string.find(line, pattern) then
                exclude = true
                break
            end
        end

        -- If exclude is false, keep line in filtered version
        if exclude == false then
            filtered_text = filtered_text .. "\n" .. line
        end
    end

    -- Try to open output file
    local output_file = io.open(M.options.output_path, "w")
    if not output_file then
        -- The file or directory doesn't exist yet, so create it
        os.execute("mkdir -p " .. M.options.output_dir)
        output_file = io.open(M.options.output_path, "w")
    end

    -- File is still nil, error during opening / creation
    if not output_file then
        error("Could not open or create output file.")
        return
    else
        -- Write in ouput file
        output_file:write(filtered_text)
        -- Close output file
        output_file:close()
    end

    -- Finally, reload LSP
    vim.api.nvim_command("LspRestart")
end

-- Define default parameters
local defaults = {
    input_path = "Debug/compile_commands.json", -- Path to input file
    output_path = "build/compile_commands.json", -- Path to ouput file
    excludes = { -- List of patterns to exclude from file
        "fcyclomatic",
    },
}

-- Define setup function
function M.setup(options)
    -- Merge default and provided options
    options = vim.tbl_deep_extend("force", defaults, options or {})

    -- Define formatted options
    local options_formatted = {}

    -- Save the provided paths into the module
    options_formatted.input_path = options.input_path
    options_formatted.output_path = options.output_path

    -- Slice ouput path provided into output dir and file
    options_formatted.input_dir = string.match(options.input_path, "^(.*/)")
    options_formatted.input_file = string.sub(
    options.input_path,
    #options_formatted.input_dir + 1
    )

    -- Do the same for the output
    options_formatted.output_dir = string.match(options.output_path, "^(.*/)")
    options_formatted.output_file = string.sub(
    options.output_path,
    #options_formatted.output_dir + 1
    )

    -- Add excludes to options
    options_formatted.excludes = options.excludes

    -- Set module's options
    M.options = options_formatted
end

-- Return the module object
return M
