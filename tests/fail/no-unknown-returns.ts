// From pi-processes .pi/extensions-disabled/dev-events-log.ts
export function sanitizeForJson(value: object, seen = new WeakSet<object>()): unknown {
  return value;
}

export async function readSnapshot(path: string): Promise<unknown> {
  return {};
}

const toRaw = (raw: string): unknown => raw;

type Loader = (path: string) => unknown;

interface Store {
  load(key: string): unknown;
}
