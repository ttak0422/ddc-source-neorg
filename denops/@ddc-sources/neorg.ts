import {
  getBuiltinElements,
  getLanguages,
  getMediaTypes,
  getTasks,
} from "../neorg/complete.ts";
import { source, types } from "../neorg/deps/ddc.ts";
import { Context } from "../neorg/types.ts";
import { UserData } from "./../neorg/deps/lsp.ts";

export type Params = {
  [K in PropertyKey]: never;
};

export class Source extends source.BaseSource<Params> {
  override params(): Params {
    return {};
  }

  override async gather(
    { denops, context, completePos, onCallback }: source.GatherArguments<
      Params
    >,
  ): Promise<types.DdcGatherItems<UserData>> {
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
      getMediaTypes(ctx),
      getLanguages(ctx),
      getTasks(ctx),
    ]).then((results) => results.flat());

    return completions;
  }
}
