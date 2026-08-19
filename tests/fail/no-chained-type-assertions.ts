// From pi-ts-aperture extensions/aperture/dedicated/runtime.ts
type ProviderModelConfig = { id: string; label: string };
interface Model<Api> {
  id: string;
  api: Api;
}
interface CatalogEntry {
  models: object[];
}

export function toProviderModels(entry: CatalogEntry): ProviderModelConfig[] {
  return entry.models as unknown as ProviderModelConfig[];
}

export function toModels<Api>(catalog: object): Model<Api>[] {
  return catalog as unknown as Model<Api>[];
}

// From pi-ts-aperture extensions/aperture/settings/shared.ts
type ApertureConfig = { theme: string };

export function mergeResolved(resolved: object) {
  return {
    ...(resolved as unknown as ApertureConfig),
  };
}
