export * from "https://deno.land/x/vscode_languageserver_types@v0.1.0/mod.ts";

export type UserData = {
  // stringifyed CompletionItem (https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItem)
  lspitem: string;
};
