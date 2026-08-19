// From pi-guardrails src/shared/config/migration/002-strip-toolchain-fields.ts
type GuardrailsConfig = { features?: object };

export function shouldRun(config: GuardrailsConfig): boolean {
  const raw = config as Record<string, unknown>;
  return "packageManager" in raw;
}

// From pi-guardrails src/shared/events.ts
interface ToolCallEvent {
  input?: Record<string, unknown>;
}

// From pi-processes extensions/processes/i18n/translator.ts
type TranslateParams = Record<string, unknown>;

// Index-signature dictionary forms.
type LegacyMetadata = { [key: string]: object };
type EventAttributes = { [name: string]: unknown };
