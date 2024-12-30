import { Context } from "./types.ts";
import { UserData } from "./deps/lsp.ts";
import { getLanguageList } from "./bindings.ts";
import { Item } from "jsr:@shougo/ddc-vim@~9.1.0/types";

const makeSimpleStaticCompletion: (opt: {
  pattern: RegExp;
  candinates: string[];
}) => (ctx: Context) => Promise<Item<UserData>[]> = (opt) =>
  (() => {
    return (ctx) => {
      if (!opt.pattern.test(ctx.input)) {
        return Promise.resolve([]);
      }
      return Promise.resolve(opt.candinates.map((c) => ({ word: c })));
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
