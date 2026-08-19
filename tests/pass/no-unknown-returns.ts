type JsonValue = string | number | boolean | null;
type ApertureProvider = { id: string };

export function sanitizeForJson(value: object): JsonValue {
  return String(value);
}

export async function readSnapshot(path: string): Promise<ApertureProvider | null> {
  return null;
}

const toRaw = (raw: string): JsonValue => raw;

type Loader = (path: string) => JsonValue;

interface Store {
  load(key: string): ApertureProvider;
}
