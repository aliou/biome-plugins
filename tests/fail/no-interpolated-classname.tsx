// Template literal in className should trigger.
const active = true;
const el = <div className={`container ${active ? "active" : ""}`}>hello</div>;
