/**
 * issue id for ddc.
 *
 * @example
 * ```
 * issueId(); // 1
 * issueId(); // 2
 * issueId(); // 3
 * ...
 * issueId(); // 1000
 * issueId(); // 1
 * issueId(); // 2
 * ...
 * ```
 */
export const issueId = (() => {
  let counter = 0;
  return () => `neorg/${(counter++) % 1000}`;
})();
