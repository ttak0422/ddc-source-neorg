import { path } from "./deps/std.ts";
import { Context, Language, toLanguage } from "./types.ts";
import { issueId } from "./util.ts";

export async function getCurrentBuffer(ctx: Context): Promise<string> {
  const id = issueId();
  const [path] = await Promise.all([
    ctx.callback(id) as Promise<string>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['get-current-buffer'](_A.id)",
      { id },
    ),
  ]);
  return path;
}

export async function getLanguageList(ctx: Context): Promise<Language[]> {
  const id = issueId();
  const [{ languages }] = await Promise.all([
    ctx.callback(id) as Promise<{ languages: string[] }>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['get-language-list'](_A.id)",
      { id },
    ),
  ]);
  return languages.map(toLanguage);
}

export async function getCurrentWorkspace(ctx: Context): Promise<{
  name: string;
  path: URL;
}> {
  const id = issueId();
  const [workspace] = await Promise.all([
    ctx.callback(id) as Promise<{ name: string; path: string }>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['get-current-workspace'](_A.id)",
      { id },
    ),
  ]);
  return {
    name: workspace.name,
    path: path.toFileUrl(workspace.path),
  };
}

export async function getAnchorList(ctx: Context): Promise<string[]> {
  const id = issueId();
  const [anchors] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['get-anchor-list'](_A.id)",
      { id },
    ),
  ]);
  return anchors;
}
