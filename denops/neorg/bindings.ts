import { Context, HeadingLevel, Language, toLanguage } from "./types.ts";
import { issueId } from "./util.ts";

export async function getCurrentBuffer(ctx: Context): Promise<string> {
  const id = issueId();
  const [path] = await Promise.all([
    ctx.callback(id) as Promise<string>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').current_buffer(_A.id)",
      { id },
    ),
  ]);
  return path;
}

export async function getCurrentWorkspace(ctx: Context): Promise<{
  name: string;
  path: string;
}> {
  const id = issueId();
  const [workspace] = await Promise.all([
    ctx.callback(id) as Promise<{ name: string; path: string }>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').current_workspace(_A.id)",
      { id },
    ),
  ]);
  return {
    name: workspace.name,
    path: workspace.path,
  };
}

export async function getLanguageList(ctx: Context): Promise<Language[]> {
  const id = issueId();
  const [languages] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').language_list(_A.id)",
      { id },
    ),
  ]);
  return languages.map(toLanguage);
}

export async function getAnchorList(ctx: Context): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').anchor_list(_A.id)",
      { id },
    ),
  ]);
  return items;
}

export async function getLocalHeadingList(
  ctx: Context,
  level: HeadingLevel,
): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['local'].heading_list(_A.id, _A.level)",
      { id, level },
    ),
  ]);
  return items;
}

export async function getLocalFootnoteList(ctx: Context): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['local'].footnote_list(_A.id)",
      { id },
    ),
  ]);
  return items;
}

export async function getLocalDefinitionList(ctx: Context): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['local'].definition_list(_A.id)",
      { id },
    ),
  ]);
  return items;
}

export async function getLocalGenericList(ctx: Context): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['local'].generic_list(_A.id)",
      { id },
    ),
  ]);
  return items;
}
export async function getForeignHeadingList(
  ctx: Context,
  path: string,
  level: HeadingLevel,
): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').foreign.heading_list(_A.id, _A.path, _A.level)",
      { id, path, level },
    ),
  ]);
  return items;
}

export async function getForeignFootnoteList(
  ctx: Context,
  path: string,
): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').foreign.footnote_list(_A.id, _A.path)",
      { id, path },
    ),
  ]);
  return items;
}

export async function getForeignDefiinitionList(
  ctx: Context,
  path: string,
): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').foreign.definition_list(_A.id, _A.path)",
      { id, path },
    ),
  ]);
  return items;
}

export async function getForeignGenericList(
  ctx: Context,
  path: string,
): Promise<string[]> {
  const id = issueId();
  const [items] = await Promise.all([
    ctx.callback(id) as Promise<string[]>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg').foreign.generic_list(_A.id, _A.path)",
      { id, path },
    ),
  ]);
  return items;
}
