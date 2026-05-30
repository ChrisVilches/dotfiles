local no_lsp = "No LSP"

local function format_lsp_progress(messages)
  if #messages > 0 then
    return " " .. table.concat(messages, " ")
  end

  local active_clients = vim.lsp.get_clients { bufnr = 0 }

  if #active_clients <= 0 then
    return no_lsp
  end

  local client_names = {}
  for _, client in ipairs(active_clients) do
    if client and client.name ~= "" then
      table.insert(client_names, " " .. client.name)
    end
  end

  return table.concat(client_names, " ")
end

local function format_treesitter_status()
  local buf = vim.api.nvim_get_current_buf()

  if vim.bo.filetype == "" then
    -- This is crucial because without a filetype, Treesitter cannot locate its parser.
    return "no filetype"
  end

  -- Other good icons:
  -- 󰐆 󰔱 󰆧 󰙅 󰳐 󱏒
  if vim.treesitter.highlighter.active[buf] then
    return "󰙅" -- Treesitter is OK and using its highlighter
  end

  if vim.treesitter.get_parser(buf) then
    return "󰀦" -- Treesitter parser exists, but it is not highlighting
  end

  return "󰅚" -- Treesitter is completely disabled for this file
end

return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    { "linrongbin16/lsp-progress.nvim", config = true },
  },
  config = function()
    -- These are for the lsp-progress block.
    vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = "lualine_augroup",
      pattern = "LspProgressStatusUpdated",
      callback = function()
        require("lualine").refresh()
      end,
    })

    require("lsp-progress").setup {
      format = format_lsp_progress,
    }

    require("lualine").setup {
      sections = {
        lualine_b = {
          "branch",
          "diff",
          {
            function()
              return vim.g.colors_name
            end,
          },
        },
        lualine_c = {
          function()
            local res = require("lsp-progress").progress()

            -- This is necessary because sometimes the plugin above doesn't
            -- output anything.
            if #res == 0 then
              return no_lsp
            end

            return res
          end,
          format_treesitter_status,
        },
      },
    }
  end,
}
