// All of these should trigger errors.

import { foo } from "./foo.ts";
import type { Bar } from "./bar.ts";
import baz from "./baz.ts";
import "./side-effect.ts";
import nested from "@scope/pkg/nested.ts";
export { thing } from "./thing.ts";
export * from "./all.ts";
export { a, b, c } from "./abc.ts";
