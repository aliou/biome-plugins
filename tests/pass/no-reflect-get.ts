interface ProviderRecord {
  apiKey?: string;
  baseUrl?: string;
}

export function readProviderField(record: ProviderRecord, key: "apiKey" | "baseUrl") {
  return record[key];
}

export function readConfig(raw: string): ProviderRecord {
  const record: ProviderRecord = {};
  for (const entry of raw.split(",")) {
    const [key, value] = entry.split("=");
    if (key === "apiKey" || key === "baseUrl") {
      record[key] = value;
    }
  }
  return record;
}
