local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local CODE_ACTION = methods.internal.CODE_ACTION

local cspell_diagnostics = function(bufnr, lnum, cursor_col)
    local diagnostics = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr, { lnum = lnum })) do
        if diagnostic.source == "cspell" and cursor_col >= diagnostic.col and cursor_col < diagnostic.end_col then
            table.insert(diagnostics, diagnostic)
        end
    end
    return diagnostics
end

return h.make_builtin({
    name = "cspell",
    meta = {
        url = "https://github.com/streetsidesoftware/cspell",
        description = "cspell is a spell checker for code.",
    },
    method = CODE_ACTION,
    filetypes = {},
    generator = {
        fn = function(params)
            local actions = {}
            local diagnostics = cspell_diagnostics(params.bufnr, params.row - 1, params.col)
            if vim.tbl_isempty(diagnostics) then
                return nil
            end
            for _, diagnostic in ipairs(diagnostics) do
                for _, suggestion in ipairs(diagnostic.user_data.suggestions) do
                    table.insert(actions, {
                        title = string.format("Use %s", suggestion),
                        action = function()
                            vim.api.nvim_buf_set_text(
                                diagnostic.bufnr,
                                diagnostic.lnum,
                                diagnostic.col,
                                diagnostic.end_lnum,
                                diagnostic.end_col,
                                { suggestion }
                            )
                        end,
                    })
                end
            end
            return actions
        end,
    },
})
