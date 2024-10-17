return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require "harpoon"
    local conf = require("telescope.config").values
    harpoon:setup {}

    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      if #file_paths == 0 then
        print "No files"
        return
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
          initial_mode = "normal",
        })
        :find()
    end

    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "Harpoon Add" })

    vim.keymap.set("n", "<leader>h", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon Open telescope" })

    -- The non-telescope one allows deletions (use 'dd' and save buffer).
    -- (Note: There's a trick to delete buffers using Telescope, but it requires a bunch of custom code)
    vim.keymap.set("n", "<leader>H", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon Open vanilla window" })
  end,
}
