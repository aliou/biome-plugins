import { homedir } from "os";
import { userInfo } from "node:os";

const home = homedir();
const user = userInfo();
const envHome = process.env.HOME;
const envHomeBracket = process.env["HOME"];
