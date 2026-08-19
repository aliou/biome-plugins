// Named value types parsed with a schema are the rule's fix.
type ToolInput = { command: string; args: string[] };

interface ToolCallEvent {
  input?: ToolInput;
}

type ProviderModelConfig = { id: string; label: string };
type ProviderModelMap = Record<string, ProviderModelConfig>;

type EventAttributes = { command: string; status: number };
type TranslateParams = { [key: string]: string };
