import { assertEquals, assertFalse, assertTrue } from "../test_util.ts";

// MEMO: definition assuming input before cursor

export const topLevelTag = /@\w*$/;

export const documentTag = /@document\.?\w*$/;

export const imageTag = /@image\s\w*$/;

export const codeTag = /@code\s\w*$/;

export const task = /[-*$~\^]\s\([^)]*$/;

export const localLink = /\{([\^#]|\*+)((?:\s\w*)|\s?)$/;

export const foreignLink = /\{:(.+):([\^#]|\*+)((?:\s\w*)|\s?)$/;

export const neighborhoodLink = /\{(?:[#$\^]|\*+) ([^}]*)\}\[/;

export const anchor = /.*(?:[^}]\[)|(?:^\[)/;

export const file = /\{:[^:}]*$/;

Deno.test("topLevelTag", () => {
  assertTrue(topLevelTag.test("@"));
  assertTrue(topLevelTag.test("@do"));
  assertFalse(topLevelTag.test("@code "));
});

Deno.test("documentTag", () => {
  assertTrue(documentTag.test("@document"));
  assertTrue(documentTag.test("@document."));
  assertTrue(documentTag.test("@document.ta"));
  assertFalse(documentTag.test("@document.tag "));
});

Deno.test("imageTag", () => {
  assertTrue(imageTag.test("@image "));
  assertTrue(imageTag.test("@image pn"));
  assertFalse(imageTag.test("@image png "));
});

Deno.test("codeTag", () => {
  assertTrue(codeTag.test("@code "));
  assertTrue(codeTag.test("@code py"));
  assertFalse(codeTag.test("@code python "));
});

Deno.test("task", () => {
  assertTrue(task.test("- ("));
  assertTrue(task.test("* ("));
  assertTrue(task.test("$ ("));
  assertTrue(task.test("~ ("));
  assertTrue(task.test("^ ("));
  assertFalse(task.test("- ( )"));
  assertFalse(task.test("- ( ) "));
});

Deno.test("localLink", () => {
  assertFalse(localLink.test("{"));
  assertFalse(localLink.test("{foo"));
  assertFalse(localLink.test("{foo:"));
  assertFalse(localLink.test("{foo:*"));
  assertFalse(localLink.test("{foo:* bar"));
  // heading
  assertTrue(localLink.test("{**"));
  assertEquals(localLink.exec("{**")?.[1], "**");
  assertEquals(localLink.exec("{**")?.[2], "");
  assertTrue(localLink.test("{** ti"));
  assertEquals(localLink.exec("{** ti")?.[1], "**");
  assertEquals(localLink.exec("{** ti")?.[2], " ti");
  assertTrue(localLink.test(" {** "));
  assertEquals(localLink.exec(" {** ")?.[1], "**");
  assertEquals(localLink.exec(" {** ")?.[2], " ");
  assertTrue(localLink.test(" {** ti"));
  assertEquals(localLink.exec(" {** ti")?.[1], "**");
  assertEquals(localLink.exec(" {** ti")?.[2], " ti");
  // footnote
  assertTrue(localLink.test("{^"));
  assertEquals(localLink.exec("{^")?.[1], "^");
  assertEquals(localLink.exec("{^")?.[2], "");
  assertTrue(localLink.test("{^ fo"));
  assertEquals(localLink.exec("{^ fo")?.[1], "^");
  assertEquals(localLink.exec("{^ fo")?.[2], " fo");
  assertTrue(localLink.test(" {^ "));
  assertEquals(localLink.exec(" {^ ")?.[1], "^");
  assertEquals(localLink.exec(" {^ ")?.[2], " ");
  assertTrue(localLink.test(" {^ fo"));
  assertEquals(localLink.exec(" {^ fo")?.[1], "^");
  assertEquals(localLink.exec(" {^ fo")?.[2], " fo");
  // generic
  assertTrue(localLink.test("{#"));
  assertEquals(localLink.exec("{#")?.[1], "#");
  assertEquals(localLink.exec("{#")?.[2], "");
  assertTrue(localLink.test("{# fo"));
  assertEquals(localLink.exec("{# fo")?.[1], "#");
  assertEquals(localLink.exec("{# fo")?.[2], " fo");
  assertTrue(localLink.test(" {# "));
  assertEquals(localLink.exec(" {# ")?.[1], "#");
  assertEquals(localLink.exec(" {# ")?.[2], " ");
  assertTrue(localLink.test(" {# fo"));
  assertEquals(localLink.exec(" {# fo")?.[1], "#");
  assertEquals(localLink.exec(" {# fo")?.[2], " fo");
});

Deno.test("foreignLink", () => {
  assertFalse(foreignLink.test("{:foo:"));
  // heading
  assertTrue(foreignLink.test("{:foo:**"));
  assertEquals(foreignLink.exec("{:foo:**")?.[1], "foo");
  assertEquals(foreignLink.exec("{:foo:**")?.[2], "**");
  assertEquals(foreignLink.exec("{:foo:**")?.[3], "");
  assertTrue(foreignLink.test("{:foo:** ti"));
  assertEquals(foreignLink.exec("{:foo:** ti")?.[1], "foo");
  assertEquals(foreignLink.exec("{:foo:** ti")?.[2], "**");
  assertEquals(foreignLink.exec("{:foo:** ti")?.[3], " ti");
  assertTrue(foreignLink.test(" {:foo:** "));
  assertEquals(foreignLink.exec(" {:foo:** ")?.[1], "foo");
  assertEquals(foreignLink.exec(" {:foo:** ")?.[2], "**");
  assertEquals(foreignLink.exec(" {:foo:** ")?.[3], " ");
  assertTrue(foreignLink.test(" {:foo:** ti"));
  assertEquals(foreignLink.exec(" {:foo:** ti")?.[1], "foo");
  assertEquals(foreignLink.exec(" {:foo:** ti")?.[2], "**");
  assertEquals(foreignLink.exec(" {:foo:** ti")?.[3], " ti");
  // footnote
  assertTrue(foreignLink.test("{:foo:^"));
  assertEquals(foreignLink.exec("{:foo:^")?.[1], "foo");
  assertEquals(foreignLink.exec("{:foo:^")?.[2], "^");
  assertEquals(foreignLink.exec("{:foo:^")?.[3], "");
  assertTrue(foreignLink.test("{:foo:^ fo"));
  assertEquals(foreignLink.exec("{:foo:^ fo")?.[1], "foo");
  assertEquals(foreignLink.exec("{:foo:^ fo")?.[2], "^");
  assertEquals(foreignLink.exec("{:foo:^ fo")?.[3], " fo");
  assertTrue(foreignLink.test(" {:foo:^ "));
  assertEquals(foreignLink.exec(" {:foo:^ ")?.[1], "foo");
  assertEquals(foreignLink.exec(" {:foo:^ ")?.[2], "^");
  assertEquals(foreignLink.exec(" {:foo:^ ")?.[3], " ");
  assertTrue(foreignLink.test(" {:foo:^ fo"));
  assertEquals(foreignLink.exec(" {:foo:^ fo")?.[1], "foo");
  assertEquals(foreignLink.exec(" {:foo:^ fo")?.[2], "^");
  assertEquals(foreignLink.exec(" {:foo:^ fo")?.[3], " fo");
  // generic
  assertTrue(foreignLink.test("{:foo:#"));
  assertEquals(foreignLink.exec("{:foo:#")?.[1], "foo");
  assertEquals(foreignLink.exec("{:foo:#")?.[2], "#");
  assertEquals(foreignLink.exec("{:foo:#")?.[3], "");
  assertTrue(foreignLink.test("{:foo:# fo"));
  assertEquals(foreignLink.exec("{:foo:# fo")?.[1], "foo");
  assertEquals(foreignLink.exec("{:foo:# fo")?.[2], "#");
  assertEquals(foreignLink.exec("{:foo:# fo")?.[3], " fo");
  assertTrue(foreignLink.test(" {:foo:# "));
  assertEquals(foreignLink.exec(" {:foo:# ")?.[1], "foo");
  assertEquals(foreignLink.exec(" {:foo:# ")?.[2], "#");
  assertEquals(foreignLink.exec(" {:foo:# ")?.[3], " ");
  assertTrue(foreignLink.test(" {:foo:# fo"));
  assertEquals(foreignLink.exec(" {:foo:# fo")?.[1], "foo");
  assertEquals(foreignLink.exec(" {:foo:# fo")?.[2], "#");
  assertEquals(foreignLink.exec(" {:foo:# fo")?.[3], " fo");
});

Deno.test("neighborhoodLink", () => {
  assertTrue(neighborhoodLink.test(" {*** foo}["));
  assertEquals(neighborhoodLink.exec(" {*** foo}[")?.[1], "foo");
  assertTrue(neighborhoodLink.test(" {^ foo}["));
  assertTrue(neighborhoodLink.test(" {# foo bar}["));
  assertEquals(neighborhoodLink.exec(" {# foo bar}[")?.[1], "foo bar");
  assertTrue(neighborhoodLink.test(" {$ foo bar baz}["));
  assertFalse(neighborhoodLink.test(" {*** foo}"));
  assertFalse(neighborhoodLink.test(" {^ foo}"));
  assertFalse(neighborhoodLink.test(" {# foo bar}"));
  assertFalse(neighborhoodLink.test(" {$ foo bar baz}"));
  assertTrue(neighborhoodLink.test(" {*** foo}[fo"));
  assertEquals(neighborhoodLink.exec(" {*** foo}[fo")?.[1], "foo");
});

Deno.test("anchor", () => {
  assertTrue(anchor.test("["));
  assertTrue(anchor.test("test ["));
  assertFalse(anchor.test("}["));
});

Deno.test("file", () => {
  assertTrue(file.test("{:"));
  assertTrue(file.test("a {:"));
  assertTrue(file.test("{:$/"));
  assertFalse(file.test("{:a:}"));
});
