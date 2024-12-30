import { Context } from "./types.ts";
import { CompletionItem, UserData } from "./deps/lsp.ts";
import { getLanguageList } from "./bindings.ts";
import { Item } from "jsr:@shougo/ddc-vim@~9.1.0/types";

// get languages if available.
export const getLanguages: (ctx: Context) => Promise<Item<UserData>[]> =
  (() => {
    const pattern = /^\s*@code\s(\w)*/;
    return async (ctx) => {
      const matches = pattern.exec(ctx.input);
      if (matches === null) {
        return [];
      }
      const languagePrefix = matches[1];
      const candinates = await getLanguageList(ctx);

      return candinates.map((c) => {
        const index = c.indexOf(languagePrefix);
        if (index < 0) {
          return undefined;
        }
        const lspItem: CompletionItem = {
          label: c,
          textEdit: {
            newText: c,
            range: {
              start: {
                line: ctx.lineNr,
                character: ctx.completePos,
              },
              end: {
                line: ctx.lineNr,
                character: ctx.completePos + c.length,
              },
            },
          },
        };
        const item: Item<UserData> = {
          word: c,
          user_data: { lspitem: JSON.stringify(lspItem) },
        };
        return item;
      })
        .filter((c) => c !== undefined);
    };
  })();
