return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          auto_refresh = true,
          layout = {
            position = "bottom",
            radio = 0.5,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          accept = false,
          auto_trigger = false,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      })
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "cat /home/gabrielbvicari/.config/nvim/openapi.env",
        openai_params = {
          model = "o1-preview",
          frequency_penalty = 0,
          presence_penalty = 0,
          max_tokens = 4095,
          temperature = 0.2,
          top_p = 0.1,
          n = 1,
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "greggh/claude-code.nvim",
    event = "VeryLazy",
    config = function()
      -- Create global variables to store the buffer and window
      local claude_buf = nil
      local claude_win = nil
      local claude_job_id = nil

      local function open_claude_popup(resume)
        local command = resume and "/home/gabrielbvicari/.npm-global/bin/claude --resume" or "/home/gabrielbvicari/.npm-global/bin/claude"

        if claude_win and vim.api.nvim_win_is_valid(claude_win) then
          vim.api.nvim_set_current_win(claude_win)
          vim.cmd("startinsert")
          return
        end

        if
          claude_buf
          and vim.api.nvim_buf_is_valid(claude_buf)
          and claude_job_id
          and vim.fn.jobwait({ claude_job_id }, 0)[1] == -1
        then
          local width = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.8)
          local row = math.floor((vim.o.lines - height) / 2)
          local col = math.floor((vim.o.columns - width) / 2)

          claude_win = vim.api.nvim_open_win(claude_buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
            title = " Claude Code ",
            title_pos = "center",
          })

          vim.api.nvim_win_set_option(claude_win, "winblend", 0)
          vim.cmd("startinsert")
          return
        end

        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        claude_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(claude_buf, "bufhidden", "hide") -- Changed from "wipe" to "hide"

        claude_win = vim.api.nvim_open_win(claude_buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
          title = " Claude Code ",
          title_pos = "center",
        })

        vim.api.nvim_win_set_option(claude_win, "winblend", 0)

        claude_job_id = vim.fn.termopen(command)

        vim.api.nvim_buf_set_keymap(claude_buf, "t", "<Esc>", "<C-\\><C-n>:hide<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(claude_buf, "n", "q", ":hide<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(claude_buf, "n", "<Esc>", ":hide<CR>", { noremap = true, silent = true })

        vim.cmd("startinsert")
      end

      vim.api.nvim_create_user_command("ClaudePopup", function() open_claude_popup(false) end, {})
      vim.api.nvim_create_user_command("ClaudeResume", function() open_claude_popup(true) end, {})

      require("claude-code").setup({
        path_to_claude_code = "/home/gabrielbvicari/.npm-global/bin/claude",
        model = "claude-3-7-sonnet-20250219",
        command = "/home/gabrielbvicari/.npm-global/bin/claude",
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>ClaudePopup<cr>", desc = "Toggle Claude Code Popup" },
      { "<leader>cr", "<cmd>ClaudeResume<cr>", desc = "Toggle Claude Code Resume Popup" },
      { "<leader>ct", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code Terminal" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
