// From pi-ts-aperture src/api/client.ts
type ApertureProvider = { id: string };

export function parseProvider(value: unknown, fallbackId?: string): ApertureProvider | null {
  return null;
}

// From pi-guardrails src/shared/config/migration/005-normalize-allowed-paths.ts
export function normalizeAllowedPaths(items: unknown): string[] {
  return [];
}

// From pi-processes extensions/processes/tools/index.ts (type guard shape)
type Theme = { fg: (t: string) => string };
export function isThemeLike(value: unknown): value is Theme {
  return false;
}

interface Fetcher {
  fetch(input: unknown): void;
}
