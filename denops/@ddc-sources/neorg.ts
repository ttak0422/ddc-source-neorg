import { foreignLinkItems } from "../neorg/complete/foreign-link-completion.ts";
import { anchorItems, fileItems } from "../neorg/complete/index.ts";
import { localLinkItems } from "../neorg/complete/local-link-completion.ts";
import {
  codeTagItems,
  documentTagItems,
  imageTagItems,
  taskItems,
  topLevelTagItems,
} from "../neorg/complete/tag-literal-completion.ts";
import { source, types } from "../neorg/deps/ddc.ts";
import { CompletionItem, Context } from "../neorg/types.ts";

export type Params = {
  [K in PropertyKey]: never;
};

const sequentialLightwaightCompletion: (
  ctx: Context,
) => CompletionItem[] | undefined = (() => {
  const processes = [
    topLevelTagItems,
    documentTagItems,
    imageTagItems,
    taskItems,
  ];
  function* findCompletable(ctx: Context) {
    for (const p of processes) {
      const items = p(ctx);
      if (items.length > 0) {
        yield items;
        return undefined;
      }
    }
  }
  return (ctx) => findCompletable(ctx).next().value;
})();

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
      inputBeforeCursor: context.input.slice(0, completePos),
      completePos,
      callback: onCallback,
    };

    const completions = sequentialLightwaightCompletion(ctx);
    if (completions !== undefined) {
      return completions;
    }

    return (await Promise.allSettled([
      codeTagItems(ctx),
      localLinkItems(ctx),
      foreignLinkItems(ctx),
      anchorItems(ctx),
      fileItems(ctx),
    ]))
      .filter((r) => r.status === "fulfilled")
      .map((r) => (r as PromiseFulfilledResult<CompletionItem[]>).value)
      .flat();
  }
}
