inputs: [
  (
    _: prev:
    let
      inherit (builtins)
        listToAttrs
        getAttr
        ;
      inherit (prev.vimUtils) buildVimPlugin;
    in
    {
      vimPlugins =
        prev.vimPlugins
        // (listToAttrs (
          map
            (name: {
              inherit name;
              value = buildVimPlugin {
                buildPhase = "";
                distPhase = "";
                version = (getAttr name inputs).rev or "latest";
                pname = name;
                src = getAttr name inputs;
                dontBuild = true;
              };
            })
            [
              "denops-vim"
              "ddc-vim"
              "ddc-ui-native"
              "ddc-source-around"
              "ddc-filter-matcher_head"
              "ddc-filter-sorter_rank"
            ]
        ));
    }
  )
]
