import { foo } from "./foo";
import type { Bar } from "./bar";
import baz from "./baz";
import "./side-effect";
import nested from "@scope/pkg/nested";
import pkg from "some-package";
import data from "./data.json";
export { thing } from "./thing";
export * from "./all";
export { a, b, c } from "./abc";

declare module "*.js" {}
