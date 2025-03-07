return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require "harpoon"
    local conf = require("telescope.config").values
    harpoon:setup {}

    local removed_files = require("stack").Stack:new()

    local make_finder = function()
      local file_paths = {}
      for _, item in ipairs(harpoon:list().items) do
        table.insert(file_paths, item.value)
      end

      return require("telescope.finders").new_table { results = file_paths }
    end

    local function toggle_telescope()
      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = make_finder(),
          attach_mappings = function(prompt_bufnr, map_key)
            map_key("n", "dd", function()
              local action_state = require "telescope.actions.state"
              local selection = action_state.get_selected_entry()

              -- NOTE: harpoon:list():remove_at is bugged (it removes several items)
              -- so I have to do it like this.
              for idx, item in ipairs(harpoon:list().items) do
                if item.value == selection.value then
                  table.remove(harpoon:list().items, idx)
                  break
                end
              end

              removed_files:push(selection.value)

              print("Harpoon: removed " .. selection.value)

              action_state.get_current_picker(prompt_bufnr):refresh(make_finder())
            end)

            return true
          end,
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
          initial_mode = "normal",
        })
        :find()
    end

    local function add_file(file_path)
      harpoon:list():add { value = file_path, context = {} }
    end

    vim.keymap.set("n", "<leader>Ha", function()
      local path = vim.fn.fnamemodify(vim.fn.expand "%", ":.")
      add_file(path)
      print("Harpoon: added '" .. path .. "'")
    end, { desc = "Harpoon Add" })

    vim.keymap.set("n", "<leader>Hf", function()
      toggle_telescope()
    end, { desc = "Harpoon Open telescope" })

    vim.keymap.set("n", "<leader>Hr", function()
      if removed_files:is_empty() then
        vim.api.nvim_err_writeln "Harpoon: No files to re-add"
        return
      end

      local file = removed_files:pop()
      add_file(file)
      print("Re-added " .. file)
      toggle_telescope()
    end, { desc = "Harpoon Re-add Last Removed File" })
  end,
}
