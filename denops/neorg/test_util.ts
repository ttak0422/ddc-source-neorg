import { equals } from "./deps/std.ts";

export const { assertEquals } = equals;

export const assertTrue = (actual: boolean, msg?: string) =>
  equals.assertEquals(actual, true, msg);

export const assertFalse = (actual: boolean, msg?: string) =>
  equals.assertEquals(actual, false, msg);
