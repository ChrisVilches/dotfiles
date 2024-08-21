-- TODO: It's fine. I started to do mappings inside plugins. Just deal with that from now on.
-- TODO: Not sure about having mappings here in this file... they should be in
--       the mappings.lua file. The problem is that if I use this in the mappings file,
--       the code to open it with telescope would also need to go somewhere else.
-- vim.keymap.set("n", "<leader>a", function()
--   harpoon:list():add()
-- end, { desc = "Harpoon Add" })
--
-- vim.keymap.set("n", "<leader>h", function()
--   toggle_telescope(harpoon:list())
-- end, { desc = "Harpoon Open telescope" })
--
-- -- The non-telescope one allows deletions (use 'dd' and save buffer).
-- vim.keymap.set("n", "<leader>H", function()
--   harpoon.ui:toggle_quick_menu(harpoon:list())
-- end, { desc = "Harpoon Open vanilla window" })

-- Toggle previous & next buffers stored within Harpoon list
-- TODO: These don't work
-- vim.keymap.set("n", "<C-S-P>", function()
--   harpoon:list():prev()
-- end)
-- vim.keymap.set("n", "<C-S-N>", function()
--   harpoon:list():next()
-- end)

-- TODO: These keybindings are dumb... don't use, but consider using different ones.
-- (maybe not, just remove)
-- vim.keymap.set("n", "<C-h>", function()
--   harpoon:list():select(1)
-- end)
-- vim.keymap.set("n", "<C-t>", function()
--   harpoon:list():select(2)
-- end)
-- vim.keymap.set("n", "<C-n>", function()
--   harpoon:list():select(3)
-- end)
-- vim.keymap.set("n", "<C-s>", function()
--   harpoon:list():select(4)
-- end)
--

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

    -- TODO: Not sure about having mappings here in this file... they should be in
    --       the mappings.lua file. The problem is that if I use this in the mappings file,
    --       the code to open it with telescope would also need to go somewhere else.
    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "Harpoon Add" })

    vim.keymap.set("n", "<leader>h", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon Open telescope" })

    -- The non-telescope one allows deletions (use 'dd' and save buffer).
    vim.keymap.set("n", "<leader>H", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon Open vanilla window" })
  end,
}
