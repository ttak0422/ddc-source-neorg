import {
  getLocalFootnoteList,
  getLocalGenericList,
  getLocalHeadingList,
} from "../bindings.ts";
import { CompletionItem, Context, isHeadingLevel } from "../types.ts";
import { menu } from "./menu.ts";
import { localLink } from "./pattern.ts";

export const localLinkItems = async (
  ctx: Context,
): Promise<CompletionItem[]> => {
  const match = localLink.exec(ctx.inputBeforeCursor);
  if (match === null) {
    return [];
  }

  const tagPrefix = match[1];
  const tagSuffix = match[2];
  const padding = tagSuffix === "" ? " " : "";
  const links = await (async () => {
    switch (tagPrefix.at(0)) {
      case "*": {
        const level = tagPrefix.length;
        if (!isHeadingLevel(level)) {
          return [];
        } else {
          return await getLocalHeadingList(ctx, level);
        }
      }
      case "^":
        return await getLocalFootnoteList(ctx);
      case "#":
        return await getLocalGenericList(ctx);
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
