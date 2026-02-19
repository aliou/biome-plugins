// Top-level imports are fine.
import { useState } from "react";
import fs from "fs";
import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import type { Bar } from "./types";

const mod = await import("./module");
const pkg = require("top-level-pkg");
