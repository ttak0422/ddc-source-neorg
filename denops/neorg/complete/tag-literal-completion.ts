import { getLanguageList } from "../bindings.ts";
import { CompletionItem, Context } from "./../types.ts";
import { menu } from "./menu.ts";
import * as pattern from "./pattern.ts";

const makeSimpleStaticCompletion: (opt: {
  pattern: RegExp;
  candinates: string[] | CompletionItem[];
  menu: typeof menu[keyof typeof menu];
}) => (ctx: Context) => CompletionItem[] = (opt) => {
  return (ctx) => {
    if (
      !opt.pattern.test(ctx.inputBeforeCursor) || opt.candinates.length === 0
    ) {
      return [];
    }
    if (typeof opt.candinates[0] === "string") {
      const cs = opt.candinates as string[];
      return cs.map((c) => ({ word: c, menu: opt.menu }));
    } else {
      const cs = (opt.candinates as CompletionItem[]).map((c) => ({
        ...c,
        menu: opt.menu,
      }));
      return cs;
    }
  };
};

export const topLevelTagItems: (ctx: Context) => CompletionItem[] =
  makeSimpleStaticCompletion({
    pattern: pattern.topLevelTag,
    candinates: [
      "code",
      "image",
      "document",
    ],
    menu: menu.tag,
  });

export const documentTagItems: (ctx: Context) => CompletionItem[] =
  makeSimpleStaticCompletion({
    pattern: pattern.documentTag,
    candinates: ["meta"],
    menu: menu.tag,
  });

export const imageTagItems: (ctx: Context) => CompletionItem[] =
  makeSimpleStaticCompletion({
    pattern: pattern.imageTag,
    candinates: [
      "jpeg",
      "png",
      "svg",
      "jfif",
      "exif",
    ],
    menu: menu.format,
  });

export const codeTagItems = async (ctx: Context): Promise<CompletionItem[]> => {
  if (!pattern.codeTag.test(ctx.inputBeforeCursor)) {
    return [];
  }

  const candinates = await getLanguageList(ctx);
  return candinates.map((c) => ({ word: c, menu: menu.language }));
};

export const taskItems: (ctx: Context) => CompletionItem[] =
  makeSimpleStaticCompletion({
    pattern: pattern.task,
    // lighweight impl
    candinates: [
      { word: " ) ", abbr: "( ) undone" },
      { word: "-) ", abbr: "(-) pending" },
      { word: "x) ", abbr: "(x) done" },
      { word: "_) ", abbr: "(_) cancelled" },
      { word: "!) ", abbr: "(!) important" },
      { word: "+) ", abbr: "(+) recurring" },
      { word: "=) ", abbr: "(=) on hold" },
      { word: "?) ", abbr: "(?) uncertain" },
    ],
    menu: menu.todo,
  });
