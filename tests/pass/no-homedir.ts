import { cpus, platform, type } from "os";
import { tmpdir, networkInterfaces } from "node:os";
import * as os from "os";
import { homedir } from "./paths";

const path = process.env.PATH;
const user = process.env.USER;
