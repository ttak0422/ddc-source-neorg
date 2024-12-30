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
      const matches = opt.pattern.exec(ctx.input);
      if (matches === null) {
        return Promise.resolve([]);
      }
      return Promise.resolve(opt.candinates.map((c) => ({ word: c })));
    };
  })();

export const getBuiltinElements: (ctx: Context) => Promise<Item<UserData>[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@(\w)*/,
    candinates: [
      "code",
      "image",
      "document",
    ],
  });

export const getMediaTypes: (ctx: Context) => Promise<Item<UserData>[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@image\s(\w)*/,
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
    const pattern = /^\s*@code\s(\w)*/;
    return async (ctx) => {
      const matches = pattern.exec(ctx.input);
      if (matches === null) {
        return [];
      }
      const input = matches[1];
      const candinates = await getLanguageList(ctx);

      return candinates.map((c) => {
        if (c.indexOf(input) < 0) {
          return undefined;
        }
        const item: Item<UserData> = {
          word: c,
        };
        return item;
      })
        .filter((c) => c !== undefined);
    };
  })();
