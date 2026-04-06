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
    return (await modelRegistry.getApiKeyForProvider(SYNTHETIC_PROVIDER)) || "";
  }

  authStorage.reload();
  return (await authStorage.getApiKey(SYNTHETIC_PROVIDER)) || "";
}

export async function hasSyntheticAuth(modelRegistry: ApiKeyRegistry): Promise<boolean> {
  const hasAuth = Boolean(
    await modelRegistry.getApiKeyForProvider(SYNTHETIC_PROVIDER),
  );

  return hasAuth;
}
