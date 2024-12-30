import { Context, Language, toLanguage } from "./types.ts";
import { issueId } from "./util.ts";

export async function getLanguageList(ctx: Context): Promise<Language[]> {
  const id = issueId();
  const [{ languages }] = await Promise.all([
    ctx.callback(id) as Promise<{ id: string; languages: string[] }>,
    ctx.denops.call(
      "luaeval",
      "require('ddc_source_neorg')['get-language-list'](_A.id)",
      { id },
    ),
  ]);
  return languages.map(toLanguage);
}
