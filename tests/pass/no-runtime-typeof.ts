// The rule's fix: parse with a schema at the boundary instead of typeof checks.
// From pi-ts-aperture src/api/client.ts (typebox usage).
import { Type, type Static } from "typebox";
import { Value } from "typebox/value";

const ApertureProviderSchema = Type.Object({
  id: Type.String(),
  name: Type.String(),
});
type ApertureProvider = Static<typeof ApertureProviderSchema>;

export function parseProvider(value: object): ApertureProvider | null {
  return Value.Check(ApertureProviderSchema, value) ? (value as ApertureProvider) : null;
}

// typeof in a type position is a static type query, not a runtime check.
const defaultConfig = { theme: "dark", compact: false };
type Config = typeof defaultConfig;
