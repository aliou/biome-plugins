// From pi-processes src/utils/command-executor.ts
import { isAbsolute } from "node:path";
import { existsSync } from "node:fs";

export function isCustomShell(shell: string | boolean): boolean {
  return typeof shell === "string" && isAbsolute(shell) && existsSync(shell);
}

// From pi-guardrails src/shared/config/migration/009-allow-dev-null.ts
const DEV_NULL = "/dev/null";

export function allowsDevNull(entry: string | { pattern?: string }): boolean {
  if (typeof entry === "string") return entry === DEV_NULL;
  return entry.pattern === DEV_NULL;
}

// From pi-ts-aperture src/api/client.ts
export function hasProviders(providers: object | null): boolean {
  return providers !== null && typeof providers === "object";
}
