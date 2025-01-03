/// branded types ///

const languageBrand = Symbol();

export type Language = string & { [languageBrand]: unknown };

export function toLanguage(src: string): Language {
  return src as Language;
}

/// context ///
import { Denops } from "./deps/denops.ts";

export type Context = {
  denops: Denops;
  // ddc callback
  callback: (id: string) => Promise<unknown>;
  // current input
  input: string;
  // current input before cursor
  inputBeforeCursor: string;
  completePos: number;
};

/// neorg ///
export type HeadingLevel = 1 | 2 | 3 | 4 | 5 | 6;

export function isHeadingLevel(src: unknown): src is HeadingLevel {
  if (typeof src !== "number") {
    return false;
  }
  return [...Array(6).keys()].map((i) => i + 1).includes(src);
}

/// ddc ///
import { types } from "./deps/ddc.ts";

export type CompletionItem = types.Item;

/// util ///
export type Result<T, E = Error> = [T, undefined] | [undefined, E];
