interface ProviderRecord {
  apiKey?: string;
  baseUrl?: string;
}

export function readProviderField(record: ProviderRecord, key: string) {
  return Reflect.get(record, key);
}

export function readWithReceiver(record: ProviderRecord, key: string, receiver: object) {
  return Reflect.get(record, key, receiver);
}
