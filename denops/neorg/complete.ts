import { Context } from "./types.ts";
import { UserData } from "./deps/lsp.ts";
import { getLanguageList } from "./bindings.ts";
import { Item } from "jsr:@shougo/ddc-vim@~9.1.0/types";

const makeSimpleStaticCompletion: (opt: {
  pattern: RegExp;
  candinates: string[] | Item[];
}) => (ctx: Context) => Promise<Item<UserData>[]> = (opt) =>
  (() => {
    return (ctx) => {
      if (!opt.pattern.test(ctx.input) || opt.candinates.length === 0) {
        return Promise.resolve([]);
      }
      if (typeof opt.candinates[0] === "string") {
        const cs = opt.candinates as string[];
        return Promise.resolve(cs.map((c) => ({ word: c })));
      } else {
        return Promise.resolve(opt.candinates as Item[]);
      }
    };
  })();

export const getBuiltinElements: (ctx: Context) => Promise<Item<UserData>[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@\w*$/,
    candinates: [
      "code",
      "image",
      "document",
    ],
  });

export const getMediaTypes: (ctx: Context) => Promise<Item<UserData>[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@image\s\w*/,
    candinates: [
      "jpeg",
      "png",
      "svg",
      "jfif",
      "exif",
    ],
  });

export const getTasks: (ctx: Context) => Promise<Item<UserData>[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*[-*$~^]\s\(/,
    // lighweight impl
    candinates: [
      { word: " ) ", abbr: "( )", menu: "undone" },
      { word: "-) ", abbr: "(-)", menu: "pending" },
      { word: "x) ", abbr: "(x)", menu: "done" },
      { word: "_) ", abbr: "(_)", menu: "cancelled" },
      { word: "!) ", abbr: "(!)", menu: "important" },
      { word: "+) ", abbr: "(+)", menu: "recurring" },
      { word: "=) ", abbr: "(=)", menu: "on hold" },
      { word: "?) ", abbr: "(?)", menu: "uncertain" },
    ],
  });

// get languages if available.
export const getLanguages: (ctx: Context) => Promise<Item<UserData>[]> =
  (() => {
    const pattern = /^\s*@code\s\w*$/;
    return async (ctx) => {
      if (!pattern.test(ctx.input)) {
        return [];
      }
      const candinates = await getLanguageList(ctx);
      return candinates.map((c) => ({ word: c }));
    };
  })();
