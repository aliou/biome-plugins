type ApertureProvider = { id: string };

export function parseProvider(value: unknown, fallbackId?: string): ApertureProvider | null {
  return null;
}

export function normalizeAllowedPaths(items: unknown): string[] {
  return [];
}

type Theme = { fg: (t: string) => string };
export function isThemeLike(value: unknown): value is Theme {
  return false;
}

interface Fetcher {
  fetch(input: unknown): void;
}
