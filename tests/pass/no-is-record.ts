function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

const parsePayload = (value: unknown): Record<string, unknown> | undefined => {
  if (!isPlainObject(value)) {
    return undefined;
  }

  return value;
};

export { parsePayload };
