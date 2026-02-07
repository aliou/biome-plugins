// All of these should trigger errors.

import { foo } from "./foo.js";
import type { Bar } from "./bar.js";
import baz from "./baz.js";
import "./side-effect.js";
import nested from "@scope/pkg/nested.js";
export { thing } from "./thing.js";
export * from "./all.js";
export { a, b, c } from "./abc.js";
