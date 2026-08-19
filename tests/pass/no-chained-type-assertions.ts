// From pi-guardrails src/shared/config/migration/002-strip-toolchain-fields.ts
type GuardrailsConfig = {
  features?: Record<string, string>;
};

export function run(config: GuardrailsConfig): GuardrailsConfig {
  const cleaned = structuredClone(config);
  return cleaned as GuardrailsConfig;
}

const modes = ["fast", "slow"] as const;
const strictModes = modes as const;
