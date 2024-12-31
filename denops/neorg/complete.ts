import { fs, path } from "./deps/std.ts";
import { UserData } from "./deps/lsp.ts";
import { types } from "./deps/ddc.ts";
import { Context } from "./types.ts";
import {
  getCurrentBuffer,
  getCurrentWorkspace,
  getLanguageList,
} from "./bindings.ts";

type CompletionItem = types.Item<UserData>;

const makeSimpleStaticCompletion: (opt: {
  pattern: RegExp;
  candinates: string[] | CompletionItem[];
}) => (ctx: Context) => Promise<CompletionItem[]> = (opt) =>
  (() => {
    return (ctx) => {
      if (!opt.pattern.test(ctx.input) || opt.candinates.length === 0) {
        return Promise.resolve([]);
      }
      if (typeof opt.candinates[0] === "string") {
        const cs = opt.candinates as string[];
        return Promise.resolve(cs.map((c) => ({ word: c })));
      } else {
        return Promise.resolve(opt.candinates as CompletionItem[]);
      }
    };
  })();

export const getBuiltinElements: (ctx: Context) => Promise<CompletionItem[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@\w*$/,
    candinates: [
      "code",
      "image",
      "document",
    ],
  });

export const getDocumentElements: (ctx: Context) => Promise<CompletionItem[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@document.$/,
    candinates: ["meta"],
  });

export const getMediaTypes: (ctx: Context) => Promise<CompletionItem[]> =
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

export const getTasks: (ctx: Context) => Promise<CompletionItem[]> =
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
export const getLanguages: (ctx: Context) => Promise<CompletionItem[]> =
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

export const getFiles = async (ctx: Context): Promise<CompletionItem[]> => {
  const complete = ctx.input.length >= 2 &&
    ctx.input.slice(ctx.completePos - 2, ctx.completePos) === "{:";
  if (!complete) {
    return [];
  }
  const workspace = await getCurrentWorkspace(ctx);
  const entries = await Array.fromAsync(
    fs.walk(workspace.path, { maxDepth: 20, includeDirs: false }),
  );
  const currentDir = await getCurrentBuffer(ctx).then(path.dirname);
  const relativePaths = entries.filter((e) => e.name.endsWith(".norg"))
    .map((e) => path.relative(currentDir, e.path));

  return relativePaths.map((p) => ({ word: `$/${p}:` }));
};
