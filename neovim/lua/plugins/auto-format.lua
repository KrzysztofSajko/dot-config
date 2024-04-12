local disable_filetypes = {
    "c",
    "cpp",
}
local formatters = {
    lua = { "stylua" },
    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use a sub-list to tell conform to run *until* a formatter
    -- is found.
    -- javascript = { { "prettierd", "prettier" } },
}
-- https://github.com/stevearc/conform.nvim
return {
    "stevearc/conform.nvim",
    lazy = false,
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "[F]ormat buffer",
        },
    },
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            local disable = {}
            for _, filetype in ipairs(disable_filetypes) do
                disable[filetype] = false
            end
            return {
                timeout_ms = 500,
                lsp_fallback = disable[vim.bo[bufnr].filetype],
            }
        end,
        formatters_by_ft = formatters,
    },
}