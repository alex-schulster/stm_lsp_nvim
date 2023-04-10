-- Create module object
local M = {}

-- Check if a file exists
local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- File paths
local INPUT_PATH = "Debug/compile_commands.json"
local OUTPUT_DIR = "build"
local OUTPUT_FILE = "compile_commands.json"
local OUTPUT_PATH = OUTPUT_DIR .. "/" .. OUTPUT_FILE

function M.patch_lsp()
    -- Generate the compile_commands.json file with compiledb
    local command = "cd Debug && make clean > /dev/null && compiledb make -n all > /dev/null && cd .."

    -- Job status flag
    local job_done = false

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
    if not file_exists(INPUT_PATH) then
        -- Failed to open, abort
        error("Could not open compile_commands.json file")
        return
    end

    -- Get all the lines which do not contain the -fcyclomatic option
    local filtered_text = ""
    for line in io.lines(INPUT_PATH) do
        if not string.find(line, "fcyclomatic") then
            filtered_text = filtered_text .. "\n" .. line
        end
    end

    -- Try to open output file
    local output_file = io.open(OUTPUT_PATH, "w")
    if not output_file then
        -- The file or directory doesn't exist yet, so create it
        os.execute("mkdir -p " .. OUTPUT_DIR)
        output_file = io.open(OUTPUT_PATH, "w")
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

M.test = "Hello world"

-- Return the module object
return M
