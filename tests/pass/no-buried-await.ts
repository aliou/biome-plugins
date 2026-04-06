const SYNTHETIC_PROVIDER = "synthetic";

type ApiKeyRegistry = {
  getApiKeyForProvider(provider: string): Promise<string | undefined>;
};

const authStorage = {
  reload() {},
  async getApiKey(provider: string): Promise<string | undefined> {
    return provider;
  },
};

export async function getSyntheticApiKey(
  modelRegistry?: ApiKeyRegistry,
): Promise<string> {
  if (modelRegistry) {
    const apiKey = await modelRegistry.getApiKeyForProvider(SYNTHETIC_PROVIDER);
    return apiKey || "";
  }

  authStorage.reload();
  const apiKey = await authStorage.getApiKey(SYNTHETIC_PROVIDER);
  return apiKey || "";
}

export async function hasSyntheticAuth(modelRegistry: ApiKeyRegistry): Promise<boolean> {
  const apiKey = await modelRegistry.getApiKeyForProvider(SYNTHETIC_PROVIDER);
  const hasAuth = Boolean(apiKey);

  return hasAuth;
}
