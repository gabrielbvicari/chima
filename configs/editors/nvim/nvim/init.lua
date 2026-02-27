vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.lazy")
require("debug_docker")

-- Fix LSP sync issue
vim.lsp.handlers['textDocument/didChange'] = vim.lsp.with(
  vim.lsp.handlers['textDocument/didChange'],
  {
    syncKind = vim.lsp.protocol.TextDocumentSyncKind.Full
  }
)
--vim.cmd("colorscheme catppuccin")
--vim.cmd("colorscheme onedark_dark")
--vim.cmd("colorscheme oxocarbon")
--vim.cmd("colorscheme zenbones")
--vim.cmd("colorscheme dark_flat")
--vim.cmd("colorscheme midnight")
--vim.cmd("colorscheme tokyonight")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      if vim.bo.modifiable == false then
        vim.bo.modifiable = true
      end
    end, 10)
  end,
})

vim.api.nvim_create_user_command("FixPlugins", function()
  vim.cmd("Lazy sync")

  vim.defer_fn(function()
    vim.notify("Attempting to reload DAP UI...", vim.log.levels.INFO)

    local has_nio, nio = pcall(require, "nio")
    if not has_nio then
      vim.notify("nvim-nio not loaded properly - installing it now", vim.log.levels.WARN)

      vim.cmd("Lazy install nvim-nio")
      vim.defer_fn(function()
        vim.notify("Please restart Neovim for the changes to take effect", vim.log.levels.INFO)
      end, 2000)
      return
    end

    local has_dap, dap = pcall(require, "dap")
    if not has_dap then
      vim.notify("Failed to load nvim-dap", vim.log.levels.ERROR)
      return
    end

    local has_dapui, dapui = pcall(require, "dapui")
    if not has_dapui then
      vim.notify("Failed to load nvim-dap-ui", vim.log.levels.ERROR)
      return
    end

    dapui.setup({})
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    vim.notify("Debug plugins reloaded successfully", vim.log.levels.INFO)
  end, 1000)
end, { desc = "Fix plugins by syncing Lazy and reloading DAP UI" })

vim.api.nvim_create_user_command("FixDebugPy", function()
  local function get_python_path()
    local venv_path = vim.fn.getcwd() .. "/.venv/bin/python"
    if vim.fn.filereadable(venv_path) == 1 then
      return venv_path
    end

    local active_venv = os.getenv("VIRTUAL_ENV")
    if active_venv then
      return active_venv .. "/bin/python"
    end

    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
  end

  local python_path = get_python_path()
  vim.notify("Using Python at: " .. python_path, vim.log.levels.INFO)

  vim.notify("Installing debugpy...", vim.log.levels.INFO)
  local install_cmd = python_path .. " -m pip install --upgrade debugpy"
  vim.fn.jobstart(install_cmd, {
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("debugpy installed successfully", vim.log.levels.INFO)

        vim.defer_fn(function()
          local status_ok, dap_python = pcall(require, "dap-python")
          if status_ok then
            dap_python.setup(python_path)
            vim.notify("dap-python configured with " .. python_path, vim.log.levels.INFO)

            local dap_ok, dap = pcall(require, "dap")
            if dap_ok then
              dap.configurations.python = dap.configurations.python or {}
              table.insert(dap.configurations.python, {
                type = "python",
                request = "launch",
                name = "Python: Current File",
                program = "${file}",
                pythonPath = python_path,
                console = "integratedTerminal",
              })
              vim.notify("Debug configuration added", vim.log.levels.INFO)
            end
          else
            vim.notify("Failed to configure dap-python: " .. tostring(dap_python), vim.log.levels.ERROR)
          end
        end, 500)
      else
        vim.notify("Failed to install debugpy", vim.log.levels.ERROR)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end, { desc = "Fix Python debugging by reinstalling debugpy" })

vim.api.nvim_create_user_command("FixDapAdapter", function()
  local has_dap, dap = pcall(require, "dap")
  if not has_dap then
    vim.notify("Failed to load dap module", vim.log.levels.ERROR)
    return
  end
  dap.adapters.python = {
    type = "executable",
    command = vim.fn.exepath("python3") or vim.fn.exepath("python"),
    args = { "-m", "debugpy.adapter" },
  }

  dap.configurations.python = dap.configurations.python or {}

  dap.configurations.python = {}

  table.insert(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Python: Current File",
    program = "${file}",
    console = "integratedTerminal",
  })

  table.insert(dap.configurations.python, {
    name = "Python: Attach to Container",
    type = "python",
    request = "attach",
    connect = {
      host = "localhost",
      port = 5678,
      timeout = 10000,
    },
    mode = "remote",
    pathMappings = {
      {
        localRoot = "${workspaceFolder}",
        remoteRoot = "/workspaces/${workspaceFolderBasename}",
      },
    },
    justMyCode = false,
    redirectOutput = true,
  })
  vim.notify("Debug adapters manually configured", vim.log.levels.INFO)
end, { desc = "Fix DAP adapters configuration manually" })
