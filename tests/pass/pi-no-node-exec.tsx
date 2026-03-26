import type { ExtensionAPI } from "@anthropic/pi-sdk";

async function runGit(pi: ExtensionAPI, args: string[]) {
  const result = await pi.exec("git", args);
  return result;
}
