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
  // 0-indexed
  lineNr: number;
  completePos: number;
};
