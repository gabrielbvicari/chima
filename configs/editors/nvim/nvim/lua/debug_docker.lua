local dap = require('dap')

dap.adapters.python_docker = {
  type = 'server',
  host = '127.0.0.1',
  port = 5678,
}

table.insert(dap.configurations.python, {
  type = 'python_docker',
  request = 'attach',
  name = 'Docker: Debug Core Orchestrator (Container)',
  connect = {
    host = '127.0.0.1',
    port = function()
      local port = vim.fn.input('Debug port: ', '5678')
      return tonumber(port)
    end,
  },
  mode = 'remote',
  pathMappings = {
    {
      localRoot = "/home/gabrielbvicari/MantisAI/core-orchestrator",
      remoteRoot = "/var/task",
    },
  },
  justMyCode = false,
})

table.insert(dap.configurations.python, {
  type = 'python_docker',
  request = 'attach',
  name = 'Docker: Debug Core Orchestrator (DevContainer)',
  connect = {
    host = '127.0.0.1',
    port = function()
      local port = vim.fn.input('Debug Port: ', '5678')
      return tonumber(port)
    end,
  },
  mode = 'remote',
  pathMappings = {
    {
      localRoot = "/home/gabrielbvicari/MantisAI/core-orchestrator",
      remoteRoot = "/workspace",
    },
  },
  justMyCode = false,
})