// None of these should trigger errors.

import { foo } from "./foo";
import type { Bar } from "./bar";
import baz from "./baz";
import "./side-effect";
import nested from "@scope/pkg/nested";
import pkg from "some-package";
import { useState } from "react";
export { thing } from "./thing";
export * from "./all";
export { a, b, c } from "./abc";
import { qux } from "./qux.ts";
