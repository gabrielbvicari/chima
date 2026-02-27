# Debugging in DevContainer with Neovim

This guide explains how to use the special DevContainer debugging features added to your Neovim setup.

## Quick Start

1. **Start your DevContainer** through VS Code or directly
2. **Set breakpoints** in your code using `<leader>db`
3. **Run one of the container debug commands**:
   - `:DebugContainer orchestrator` - For debugging the Core Orchestrator
   - `:DebugContainer upload-via-url` - For debugging the Upload-via-URL service
   - `:DebugContainer data-layer` - For debugging the Data Layer service
   - `:DebugContainer api-layer` - For debugging the API Layer
   - `:DebugContainer test` - For debugging tests
   - `:DebugContainer run` - For general debugging
   - You can also use `<leader>dd` as a shortcut to start typing these commands

## Workflow for Core Orchestrator

1. Open the DevContainer in VS Code
2. Start a terminal inside the container
3. Add the following code at the start of your orchestrator:
   ```python
   import debugpy
   debugpy.listen(("0.0.0.0", 5678))
   debugpy.wait_for_client()  # This line pauses execution until debugger connects
   ```
4. Run your orchestrator normally in the container terminal
5. In Neovim, set breakpoints in the code you want to inspect
6. Run `:DebugContainer orchestrator` to connect to the waiting debugger
7. The debugging session will start and execution will continue to your first breakpoint

## Workflow for Upload-via-URL

1. Start the development container:
   ```bash
   cd /path/to/upload-via-url
   docker-compose -f docker-compose.dev.yml up -d
   ```
2. Use the provided debug script:
   ```bash
   ./.devcontainer/neovim/run-debug.sh -m app
   ```
   Or manually add debugpy to your code:
   ```python
   import debugpy
   debugpy.listen(("0.0.0.0", 5678))
   debugpy.wait_for_client()
   ```
3. In Neovim, set breakpoints in your code
4. Run `:DebugContainer upload-via-url` to connect
5. Debug the service with full step-through capability

## Workflow for API Layer

1. Start the API Layer DevContainer:
   ```bash
   cd /path/to/api-layer
   docker-compose -f docker-compose.dev.yml up -d
   ```
2. Use the provided debug script:
   ```bash
   ./.devcontainer/neovim/run-debug.sh -m app
   ```
   This script will:
   - Start the FastAPI application with debugpy enabled
   - Wait for a debugger to connect on port 5678
3. In Neovim, set breakpoints in your API Layer code
4. Run `:DebugContainer api-layer` to connect
5. The debugging session will start and execution will continue to your first breakpoint

The NeoVim configuration automatically maps the local path `/home/gabrielbvicari/MantisAI/api-layer` to the container path `/workspace` for API Layer debugging.

## Workflow for Data Layer

1. Start the data-layer container:
   ```bash
   cd /path/to/data-layer
   docker-compose up -d
   ```
2. Install debugpy in the container:
   ```bash
   docker-compose exec app bash
   pip install debugpy
   ```
3. Add debugpy to your code:
   ```python
   import debugpy
   debugpy.listen(("0.0.0.0", 5678))
   debugpy.wait_for_client()
   ```
4. In Neovim, set breakpoints in your code
5. Run `:DebugContainer data-layer` to connect
6. Debug the data-layer with full step-through capability

## Workflow for Testing

1. Open your DevContainer
2. In a terminal within the container, run:
   ```
   python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m pytest -xvs [your_test_file_or_dir]
   ```
3. In Neovim, set breakpoints in your test code
4. Run `:DebugContainer test` to connect
5. Debug your tests with full step-through capability

## Required Settings in devcontainer.json

Make sure your `.devcontainer/devcontainer.json` includes port forwarding:

```json
"forwardPorts": [5678],
```

## Debugging Controls

Once connected to the debugger:
- `<leader>dc` - Continue execution to next breakpoint
- `<leader>di` - Step into function
- `<leader>do` - Step over (next line)
- `<leader>dO` - Step out of current function
- `<leader>du` - Toggle DAP UI panels
- `<leader>dr` - Toggle debug REPL
- `<leader>dx` - Terminate debugging session

## Troubleshooting

If you encounter issues:

1. Check that port 5678 is properly forwarded
2. Make sure debugpy is installed in your container
3. Verify that you've added the debugpy code at the beginning of your script
4. Look for errors in the Neovim log (:messages)
5. Try running `:FixDebugPy` to reinstall debugpy

For detailed logs, run `:lua require('dap').set_log_level('TRACE')` before debugging.