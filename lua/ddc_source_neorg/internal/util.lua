-- [nfnl] Compiled from fnl/ddc_source_neorg/internal/util.fnl by https://github.com/Olical/nfnl, do not edit.
local function normalize_bufnr(bufnr_3f)
  local bufnr = (bufnr_3f or 0)
  if (bufnr == 0) then
    return vim.api.nvim_get_current_buf()
  else
    return bufnr
  end
end
return {normalize_bufnr = normalize_bufnr}
