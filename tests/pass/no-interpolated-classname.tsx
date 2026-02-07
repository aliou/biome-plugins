// String literals and cn() calls are fine.
import { cn } from "./utils";

const el1 = <div className="container">hello</div>;
const el2 = <div className={cn("container", active && "active")}>hello</div>;
