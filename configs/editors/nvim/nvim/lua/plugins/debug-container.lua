return {
  -- Special setup for DevContainer debugging
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, _)
      vim.api.nvim_create_user_command("DebugContainer", function(opts)
        local args = opts.args or ""
        local args_table = {}
        for arg in string.gmatch(args, "%S+") do
          table.insert(args_table, arg)
        end

        local cmd = args_table[1] or "run"
        local target = args_table[2] or ""

        local function setup_container_debug(cmd, target)
          local dap = require("dap")

          dap.configurations.python = dap.configurations.python or {}

          local non_container_configs = {}
          for _, config in ipairs(dap.configurations.python) do
            if not config.name:find("Container") then
              table.insert(non_container_configs, config)
            end
          end
          dap.configurations.python = non_container_configs

          if cmd == "run" then
            table.insert(dap.configurations.python, {
              name = "Python: Run in Container",
              type = "python",
              request = "attach",
              connect = {
                host = "localhost",
                port = 5678,
                timeout = 30000,
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
              logToFile = true,
            })

            vim.notify(
              [[
Container debugging initialized.
Before starting debugging, ensure:
1. Your container is running
2. debugpy is installed in the container
3. Port 5678 is forwarded from container to host
4. You've added code to initialize debugpy in your app:

import debugpy
debugpy.listen(("0.0.0.0", 5678))
debugpy.wait_for_client()  # This pauses execution until debugger connects
            ]],
              vim.log.levels.INFO
            )
          elseif cmd == "test" then
            table.insert(dap.configurations.python, {
              name = "Python: Test in Container",
              type = "python",
              request = "attach",
              connect = {
                host = "localhost",
                port = 5678,
                timeout = 30000,
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
              logToFile = true,
            })

            vim.notify(
              [[
Container test debugging initialized.
Before starting debugging, ensure:
1. Your container has pytest with debugpy installed
2. Port 5678 is forwarded from container to host
3. Run your tests in the container with:

python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m pytest -xvs [test_file_or_dir]
            ]],
              vim.log.levels.INFO
            )
          elseif cmd == "orchestrator" then
            table.insert(dap.configurations.python, {
              name = "Python: Run Core Orchestrator in Container",
              type = "python",
              request = "attach",
              connect = {
                host = "localhost",
                port = 5678,
                timeout = 30000,
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
              logToFile = true,
            })

            vim.notify(
              [[
Core Orchestrator debugging initialized.
Before starting, add debugpy to your orchestrator:

1. Add this near the start of your orchestrator code:
   import debugpy
   debugpy.listen(("0.0.0.0", 5678))
   debugpy.wait_for_client()

2. Make sure port 5678 is forwarded to host
3. Start your orchestrator in the container
4. Return to Neovim and press <leader>dc to connect
            ]],
              vim.log.levels.INFO
            )
          elseif cmd == "upload-via-url" then
            table.insert(dap.configurations.python, {
              name = "Python: Run Upload-via-URL in Container",
              type = "python",
              request = "attach",
              connect = {
                host = "localhost",
                port = 5678,
                timeout = 30000,
              },
              mode = "remote",
              pathMappings = {
                {
                  localRoot = "${workspaceFolder}",
                  remoteRoot = "/workspace",
                },
              },
              justMyCode = false,
              redirectOutput = true,
              logToFile = true,
            })

            vim.notify(
              [[
Upload-via-URL debugging initialized.
Before starting, run the debug script:

1. From project root: ./.devcontainer/neovim/run-debug.sh -m app
   OR manually add this to your code:
   import debugpy
   debugpy.listen(("0.0.0.0", 5678))
   debugpy.wait_for_client()

2. Make sure port 5678 is forwarded to host
3. Return to Neovim and press <leader>dc to connect
            ]],
              vim.log.levels.INFO
            )
          elseif cmd == "data-layer" then
            table.insert(dap.configurations.python, {
              name = "Python: Run Data Layer in Container",
              type = "python",
              request = "attach",
              connect = {
                host = "localhost",
                port = 5678,
                timeout = 30000,
              },
              mode = "remote",
              pathMappings = {
                {
                  localRoot = "${workspaceFolder}",
                  remoteRoot = "/app",
                },
              },
              justMyCode = false,
              redirectOutput = true,
              logToFile = true,
            })

            vim.notify(
              [[
Data Layer debugging initialized.
Before starting:

1. Run the data-layer container:
   docker-compose up -d

2. Start a shell in the container and install debugpy:
   docker-compose exec app bash
   pip install debugpy

3. Add this to your app code:
   import debugpy
   debugpy.listen(("0.0.0.0", 5678))
   debugpy.wait_for_client()

4. Make sure port 5678 is forwarded to host
5. Return to Neovim and press <leader>dc to connect
            ]],
              vim.log.levels.INFO
            )
          elseif cmd == "api-layer" then
            table.insert(dap.configurations.python, {
              name = "Python: Run API Layer in Container",
              type = "python",
              request = "attach",
              connect = {
                host = "localhost",
                port = 5678,
                timeout = 30000,
              },
              mode = "remote",
              pathMappings = {
                {
                  localRoot = "/home/gabrielbvicari/MantisAI/api-layer",
                  remoteRoot = "/workspace",
                },
              },
              justMyCode = false,
              redirectOutput = true,
              logToFile = true,
            })

            vim.notify(
              [[
API Layer debugging initialized.
Before starting:

1. From project root, run the debug script:
   ./.devcontainer/neovim/run-debug.sh -m app
   This will start the API with debugpy and wait for connection

2. Make sure port 5678 is forwarded to host
3. Return to Neovim and press <leader>dc to connect
4. The debugger will attach and resume execution to your breakpoints
            ]],
              vim.log.levels.INFO
            )
          end

          if cmd == "orchestrator" then
            dap.configurations.python[#dap.configurations.python].name = "Python: Run Core Orchestrator in Container"
          elseif cmd == "upload-via-url" then
            dap.configurations.python[#dap.configurations.python].name = "Python: Run Upload-via-URL in Container"
          elseif cmd == "data-layer" then
            dap.configurations.python[#dap.configurations.python].name = "Python: Run Data Layer in Container"
          elseif cmd == "api-layer" then
            dap.configurations.python[#dap.configurations.python].name = "Python: Run API Layer in Container"
          elseif cmd == "test" then
            dap.configurations.python[#dap.configurations.python].name = "Python: Test in Container"
          else
            dap.configurations.python[#dap.configurations.python].name = "Python: Run in Container"
          end

          return dap.configurations.python[#dap.configurations.python]
        end

        local config = setup_container_debug(cmd, target)

        local dapui = require("dapui")
        dapui.open()

        local dap = require("dap")
        dap.set_log_level("DEBUG")

        vim.notify("Connecting to debugging session in container...", vim.log.levels.INFO)

        dap.run(config)
      end, {
        nargs = "*",
        desc = "Debug in DevContainer (run|test|orchestrator|upload-via-url|data-layer|api-layer)",
        complete = function(_, _, _)
          return { "run", "test", "orchestrator", "upload-via-url", "data-layer", "api-layer" } -- Completion options
        end,
      })

      vim.keymap.set("n", "<leader>dd", ":DebugContainer ", { desc = "Debug in Container", silent = false })
    end,
  },
}