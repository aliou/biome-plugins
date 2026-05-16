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

function join(...parts: string[]): string {
  return parts.join("/");
}

async function getLogDir(): Promise<string> {
  return "logs";
}

export async function getLogPath(): Promise<string> {
  const logDir = await getLogDir();
  return join(logDir, "provider-response-headers.json");
}

export async function getNestedLogPath(): Promise<string> {
  const logDir = await getLogDir();
  return join("tmp", logDir);
}
