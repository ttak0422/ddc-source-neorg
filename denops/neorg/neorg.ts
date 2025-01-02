import { Context, Result } from "./types.ts";
import { getCurrentWorkspace } from "./bindings.ts";
import * as std from "./deps/std.ts";

/**
 * resolve neorg path.
 *
 * @param ctx context
 * @param path neorg path (e.g. `$/path/to/workspace`, `path/to/relative`)
 * @returns absolute path
 */
export const resolvePath: (
  ctx: Context,
  path: string,
) => Promise<Result<string, Error>> = (() => {
  const workspacePattern = /^\$([^\/]*)\//;
  return async (ctx, p) => {
    if (p.slice(-1) === "/") {
      return [undefined, new Error("cannot resolve directory")];
    }

    const matchWorkspace = workspacePattern.exec(p);
    if (matchWorkspace !== null) {
      if (matchWorkspace[1] === "") {
        // current workspace
        const workspace = await getCurrentWorkspace(ctx);
        const filepath =
          std.path.join(workspace.path, std.path.relative("$", p)) + ".norg";
        return [filepath, undefined];
      } else {
        // foreign workspace
        return [undefined, new Error("TODO: impl")];
      }
    }

    // TODO: relative path, absolute path
    return [undefined, new Error("TODO: impl")];
  };
})();
