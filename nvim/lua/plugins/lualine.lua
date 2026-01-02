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

return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- These are for the lsp-progress block.
    vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = "lualine_augroup",
      pattern = "LspProgressStatusUpdated",
      callback = require("lualine").refresh,
    })

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
            local res = require("lsp-progress").progress { format = format_lsp_progress }

            -- This is necessary because sometimes the plugin above doesn't
            -- output anything.
            if #res == 0 then
              return no_lsp
            end

            return res
          end,
        },
      },
    }
  end,
}
