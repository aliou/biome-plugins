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

function join(...parts: string[]): string {
  return parts.join("/");
}

async function getLogDir(): Promise<string> {
  return "logs";
}

export async function getLogPath(): Promise<string> {
  return join(await getLogDir(), "provider-response-headers.json");
}

export async function getNestedLogPath(): Promise<string> {
  return join("tmp", await getLogDir());
}
