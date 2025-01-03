import {
  getForeignFootnoteList,
  getForeignGenericList,
  getForeignHeadingList,
} from "../bindings.ts";
import { resolvePath } from "../neorg.ts";
import { CompletionItem, Context, isHeadingLevel } from "../types.ts";
import { menu } from "./menu.ts";
import { foreignLink } from "./pattern.ts";

export const foreignLinkItems = async (
  ctx: Context,
): Promise<CompletionItem[]> => {
  const match = foreignLink.exec(ctx.inputBeforeCursor);
  if (match === null) {
    return [];
  }

  const [path, err] = await resolvePath(ctx, match[1]);
  if (err !== undefined) {
    console.error(err);
    return [];
  }

  const tagPrefix = match[2];
  const tagSuffix = match[3];
  const padding = tagSuffix === "" ? " " : "";
  const links = await (async () => {
    switch (tagPrefix.at(0)) {
      case "*": {
        const level = tagPrefix.length;
        if (!isHeadingLevel(level)) {
          return [];
        } else {
          return await getForeignHeadingList(ctx, path, level);
        }
      }
      case "^":
        return await getForeignFootnoteList(ctx, path);
      case "#":
        return await getForeignGenericList(ctx, path);
      default:
        console.error(`unexpected tag: '${tagPrefix}'`);
        return [];
    }
  })();
  return links.map((l) => ({
    word: `${padding}${l}}`,
    abbr: l,
    menu: menu.reference,
  }));
};
