import { cpus, platform, type } from "os";
import { tmpdir, networkInterfaces } from "node:os";
import * as os from "os";

// Other env vars are fine
const path = process.env.PATH;
const user = process.env.USER;

// Using a configured paths utility
const home = paths.getHomeDir();
