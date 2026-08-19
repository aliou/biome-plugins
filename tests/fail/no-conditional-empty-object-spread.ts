// From pi-processes src/manager/process-output.ts
interface OutputRecord {
  appendedText: string[];
  droppedLines: number;
}

export function takeOutput(record: OutputRecord) {
  const lines = record.appendedText;
  const droppedLines = record.droppedLines;
  return {
    ...(lines.length > 0 ? { appendedText: lines } : {}),
    ...(droppedLines > 0 ? { droppedLines } : {}),
  };
}
