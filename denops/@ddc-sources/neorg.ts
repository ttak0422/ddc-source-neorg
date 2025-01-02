import {
  getAnchors,
  getBuiltinElements,
  getDocumentElements,
  getFiles,
  getLanguages,
  getLocalFootnotes,
  getLocalGenerics,
  getLocalHeadings,
  getLocalLinks,
  getMediaTypes,
  getTasks,
} from "../neorg/complete.ts";
import { source, types } from "../neorg/deps/ddc.ts";
import { Context } from "../neorg/types.ts";

export type Params = {
  [K in PropertyKey]: never;
};

/** @deprecated use individual completions instead. */
export class Source extends source.BaseSource<Params> {
  override params(): Params {
    return {};
  }

  override async gather(
    { denops, context, completePos, onCallback }: source.GatherArguments<
      Params
    >,
  ): Promise<types.DdcGatherItems> {
    const ctx: Context = {
      denops,
      input: context.input,
      lineNr: context.lineNr - 1, // to 0-indexed
      completePos,
      callback: onCallback,
    };

    // TODO: implement other completions
    const completions = await Promise.all([
      getBuiltinElements(ctx),
      getDocumentElements(ctx),
      getMediaTypes(ctx),
      getLanguages(ctx),
      getTasks(ctx),
      getFiles(ctx),
      getAnchors(ctx),
      getLocalFootnotes(ctx),
      getLocalHeadings(ctx),
      getLocalLinks(ctx),
      getLocalGenerics(ctx),
    ]).then((results) => results.flat());

    return completions;
  }
}
