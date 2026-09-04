return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    -- Only one of these is needed.
    "sindrets/diffview.nvim",        -- optional
    "esmuellert/codediff.nvim",      -- optional

    -- For a custom log pager
    "m00qek/baleia.nvim",            -- optional

    -- Only one of these is needed.
    "nvim-telescope/telescope.nvim", -- optional
    "ibhagwan/fzf-lua",              -- optional
    "nvim-mini/mini.pick",           -- optional
    "folke/snacks.nvim",             -- optional
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
  },
  config = function()
    local branch_actions = require("neogit.popups.branch.actions")
    local async = require("neogit.lib.async")
    local config = require("neogit.config")
    local event = require("neogit.lib.event")
    local git = require("neogit.lib.git")
    local hook = require("neogit.lib.hook")
    local notification = require("neogit.lib.notification")
    local FuzzyFinderBuffer = require("neogit.buffers.fuzzy_finder")

    local function fetch_remote_branch(target)
      local remote, branch = git.branch.parse_remote_branch(target)
      if remote then
        notification.info("Fetching from " .. remote .. "/" .. branch)
        git.fetch.fetch(remote, branch)
        event.send("FetchComplete", { branch = branch, remote = remote })
      end
    end

    branch_actions.checkout_local_branch = function(popup)
      local local_branches = git.refs.list_local_branches()
      local target = FuzzyFinderBuffer.new(local_branches):open_async({
        prompt_prefix = "local branch",
        refocus_status = false,
      })

      if not target then
        return
      end

      hook.run("PreBranchCheckout", { branch_name = target })

      local result = git.branch.checkout(target, popup:get_arguments())
      if result:failure() then
        notification.error(table.concat(result.stderr, "\n"))
        return
      end

      event.send("BranchCheckout", { branch_name = target })
      notification.info("Checked out branch " .. target)

      if config.values.fetch_after_checkout then
        async.void(function()
          local push_remote = git.branch.pushRemote_ref(target)
          local upstream = git.branch.upstream(target)

          if upstream then
            fetch_remote_branch(upstream)
          end

          if push_remote and push_remote ~= upstream then
            fetch_remote_branch(push_remote)
          end
        end)()
      end
    end

    require("neogit").setup()
  end,
}
