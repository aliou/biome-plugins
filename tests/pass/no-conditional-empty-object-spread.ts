interface OutputRecord {
  appendedText: string[];
  droppedLines: number;
}

// The rule's fix: build the object in statements, add fields only when present.
export function takeOutput(record: OutputRecord) {
  const lines = record.appendedText;
  const droppedLines = record.droppedLines;
  const output: Partial<OutputRecord> = {};
  if (lines.length > 0) {
    output.appendedText = lines;
  }
  if (droppedLines > 0) {
    output.droppedLines = droppedLines;
  }
  return output;
}

// Spreading real objects is fine.
export function mergeDefaults(defaults: OutputRecord, overrides: OutputRecord) {
  return { ...defaults, ...overrides };
}
