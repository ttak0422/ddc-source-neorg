{
  self',
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  mkNeovimApp = cfg: {
    type = "app";
    program = "${
      with pkgs; wrapNeovimUnstable neovim-unwrapped (neovimUtils.makeNeovimConfig cfg)
    }/bin/nvim";
  };
  readLua = path: ''
    lua << EOF
    ${readFile path}
    EOF
  '';
in
{
  neorg-builtin-completion = mkNeovimApp {
    plugins = with pkgs.vimPlugins; [
      neorg
      nvim-cmp
      cmp-buffer
    ];
    customRC = readLua ./builtin.lua;
  };
  neorg-ddc-completion = mkNeovimApp {
    plugins = with pkgs.vimPlugins; [
      neorg
      denops-vim
      ddc-vim
      ddc-ui-native
      ddc-source-around
      ddc-filter-matcher_head
      ddc-filter-sorter_rank
      self'.packages.ddc-source-neorg
    ];
    customRC = ''
      let g:denops#deno = '${pkgs.deno}/bin/deno'
      ${readFile ./ddc.vim}
      ${readLua ./ddc.lua}
    '';
  };
}
