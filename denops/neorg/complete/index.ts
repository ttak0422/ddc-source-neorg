import { fs, path } from "../deps/std.ts";
import {
  getAnchorList,
  getCurrentBuffer,
  getCurrentWorkspace,
} from "../bindings.ts";
import { CompletionItem, Context } from "../types.ts";
import { menu } from "./menu.ts";
import { foreignLink } from "./pattern.ts";
import * as pattern from "./pattern.ts";

export {
  codeTagItems,
  documentTagItems,
  imageTagItems,
  taskItems,
  topLevelTagItems,
} from "./tag-literal-completion.ts";
export { localLinkItems } from "./local-link-completion.ts";
export { foreignLinkItems } from "./foreign-link-completion.ts";

export const neighborhoodLinkItems = (ctx: Context): CompletionItem[] => {
  const match = foreignLink.exec(ctx.inputBeforeCursor);
  if (match === null) {
    return [];
  }
  return [{ word: match[1], menu: menu.reference }];
};

export const fileItems = async (ctx: Context): Promise<CompletionItem[]> => {
  if (!pattern.file.test(ctx.inputBeforeCursor)) {
    return [];
  }

  const workspace = await getCurrentWorkspace(ctx);
  const entries = await Array.fromAsync(
    fs.walk(workspace.path, { maxDepth: 20, includeDirs: false }),
  );
  const currentPath = await getCurrentBuffer(ctx);
  const relativePaths = entries.filter((e) => e.name.endsWith(".norg"))
    .filter((e) => e.path !== currentPath)
    .map((e) => path.relative(workspace.path, e.path))
    .map((p) => p.slice(0, -5)); // remove ".norg"

  return relativePaths.map((p) => ({ word: `$/${p}:`, menu: menu.file }));
};

export const anchorItems = async (ctx: Context): Promise<CompletionItem[]> => {
  if (!pattern.anchor.test(ctx.inputBeforeCursor)) {
    return [];
  }

  const anchors = await getAnchorList(ctx);
  return anchors.map((a) => ({ word: a, menu: menu.reference }));
};
