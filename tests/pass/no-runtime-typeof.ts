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

const defaultConfig = { theme: "dark", compact: false };
type Config = typeof defaultConfig;
