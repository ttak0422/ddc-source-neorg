import { Context } from "./types.ts";
import { UserData } from "./deps/lsp.ts";
import { getLanguageList } from "./bindings.ts";
import { Item } from "jsr:@shougo/ddc-vim@~9.1.0/types";

export const getBuiltinElements: (ctx: Context) => Promise<Item<UserData>[]> =
  (() => {
    const pattern = /^\s*@(\w)*/;
    const candinates = [
      "code",
      "image",
      "document",
    ];
    return (ctx) => {
      const matches = pattern.exec(ctx.input);
      if (matches === null) {
        return Promise.resolve([]);
      }
      const input = matches[1];
      const items = candinates.map((c) => {
        if (input === "" || c.indexOf(input) < 0) {
          return undefined;
        }
        const item: Item<UserData> = {
          word: c,
        };
        return item;
      }).filter((c) => c !== undefined);
      return Promise.resolve(items);
    };
  })();

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
