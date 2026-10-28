import { homedir } from "os";
import { userInfo } from "node:os";
import { cpus, homedir as home, platform, tmpdir } from "node:os";

const envHome = process.env.HOME;
const envHomeBracket = process.env["HOME"];
