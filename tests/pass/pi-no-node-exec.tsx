import type { ExtensionAPI } from "@anthropic/pi-sdk";
import { ChildProcess } from "node:child_process";
import { exec } from "./exec";

async function runGit(pi: ExtensionAPI, args: string[]) {
  return pi.exec("git", args);
}
