interface OutputRecord {
  appendedText: string[];
  droppedLines: number;
}

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

export function mergeDefaults(defaults: OutputRecord, overrides: OutputRecord) {
  return { ...defaults, ...overrides };
}
