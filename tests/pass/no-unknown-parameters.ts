// The `cause` convention is exempt: error-cause enrichment is the allowed boundary.
export function enrichError(message: string, cause: unknown): Error {
  return new Error(message, { cause });
}

type ApertureProvider = { id: string };

export function parseProvider(value: object, fallbackId?: string): ApertureProvider | null {
  return null;
}

export function normalizeAllowedPaths(items: string[]): string[] {
  return items;
}
