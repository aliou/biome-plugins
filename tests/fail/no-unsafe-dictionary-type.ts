type GuardrailsConfig = { features?: object };

export function shouldRun(config: GuardrailsConfig): boolean {
  const raw = config as Record<string, unknown>;
  return "packageManager" in raw;
}

interface ToolCallEvent {
  input?: Record<string, unknown>;
}

type TranslateParams = Record<string, unknown>;

type LegacyMetadata = { [key: string]: object };
type EventAttributes = { [name: string]: unknown };
