import { fs, path } from "./deps/std.ts";
import { types } from "./deps/ddc.ts";
import { Context, isHeadingLevel } from "./types.ts";
import {
  getAnchorList,
  getCurrentBuffer,
  getCurrentWorkspace,
  getLanguageList,
  getLocalFootnoteList,
  getLocalGenericList,
  getLocalHeadingList,
} from "./bindings.ts";

type CompletionItem = types.Item;

const menu = {
  reference: "Reference",
  file: "File",
  tag: "Tag",
  language: "Language",
  format: "Format",
  todo: "Todo",
} as const;

const makeSimpleStaticCompletion: (opt: {
  pattern: RegExp;
  candinates: string[] | CompletionItem[];
  menu: typeof menu[keyof typeof menu];
}) => (ctx: Context) => Promise<CompletionItem[]> = (opt) =>
  (() => {
    return (ctx) => {
      if (!opt.pattern.test(ctx.input) || opt.candinates.length === 0) {
        return Promise.resolve([]);
      }
      if (typeof opt.candinates[0] === "string") {
        const cs = opt.candinates as string[];
        return Promise.resolve(cs.map((c) => ({ word: c, menu: opt.menu })));
      } else {
        const cs = (opt.candinates as CompletionItem[]).map((c) => ({
          ...c,
          menu: opt.menu,
        }));
        return Promise.resolve(cs);
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
    menu: menu.tag,
  });

export const getDocumentElements: (ctx: Context) => Promise<CompletionItem[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*@document.$/,
    candinates: ["meta"],
    menu: menu.tag,
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
    menu: menu.format,
  });

export const getTasks: (ctx: Context) => Promise<CompletionItem[]> =
  makeSimpleStaticCompletion({
    pattern: /^\s*[-*$~^]\s\(/,
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

// get languages if available.
export const getLanguages: (ctx: Context) => Promise<CompletionItem[]> =
  (() => {
    const pattern = /^\s*@code\s\w*$/;
    return async (ctx) => {
      if (!pattern.test(ctx.input)) {
        return [];
      }
      const candinates = await getLanguageList(ctx);
      return candinates.map((c) => ({ word: c, menu: menu.language }));
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
  const currentPath = await getCurrentBuffer(ctx);
  const currentDir = path.dirname(currentPath);
  const relativePaths = entries.filter((e) => e.name.endsWith(".norg"))
    .filter((e) => e.path !== currentPath)
    .map((e) => path.relative(currentDir, e.path));

  return relativePaths.map((p) => ({ word: `$/${p}:`, menu: menu.file }));
};

export const getAnchors = async (ctx: Context): Promise<CompletionItem[]> => {
  const suffix = ctx.input.slice(-2);
  const complete = suffix !== "}[" && suffix.slice(-1) === "[";
  if (!complete) {
    return [];
  }
  const anchors = await getAnchorList(ctx);
  return anchors.map((a) => ({ word: a, menu: menu.reference }));
};

export const getLocalFootnotes = async (
  ctx: Context,
): Promise<CompletionItem[]> => {
  const { input } = ctx;
  if (input.slice(-2) === "{^") {
    const links = await getLocalFootnoteList(ctx);
    return links.map((l) => ({
      word: ` ${l}}`,
      abbr: l,
      menu: menu.reference,
    }));
  } else if (input.slice(-3) === "{^ ") {
    const links = await getLocalFootnoteList(ctx);
    return links.map((l) => ({ word: `${l}}`, abbr: l, menu: menu.reference }));
  } else {
    return [];
  }
};

export const getLocalHeadings: (ctx: Context) => Promise<CompletionItem[]> =
  (() => {
    const pattern = /{\*+$/;
    return async (ctx) => {
      const input = ctx.input.slice(-7);
      const match = pattern.exec(input);
      if (!match) {
        return [];
      }

      const level = match[0].length - 1;
      if (!isHeadingLevel(level)) {
        return [];
      }

      const links = await getLocalHeadingList(ctx, level);
      return links.map((l) => ({
        word: ` ${l}}`,
        abbr: l,
        menu: menu.reference,
      }));
    };
  })();

export const getLocalLinks: (ctx: Context) => Promise<CompletionItem[]> =
  (() => {
    const pattern = /^.*\{[#$*^]+ ([^}]*)}\[/;
    return (ctx) => {
      const match = pattern.exec(ctx.input);
      if (match) {
        return Promise.resolve([{ word: match[1], menu: menu.reference }]);
      }
      return Promise.resolve([]);
    };
  })();

export const getLocalGenerics = async (
  ctx: Context,
): Promise<CompletionItem[]> => {
  const { input } = ctx;
  const complete = input.slice(-2) === "{#";
  if (!complete) {
    return [];
  }
  const links = await getLocalGenericList(ctx);
  return links.map((l) => ({ word: ` ${l}}`, abbr: l, menu: menu.reference }));
};
