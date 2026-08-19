// No real-world occurrences in pi-processes/pi-ts-aperture/pi-guardrails.
// These are the forms the rule rejects so they stay at zero.

interface Command {
  (argv: string[]): number;
}

class Shell {
  status = 0;
  run(command: Command, argv: string[]): number {
    return Reflect.apply(command, this, argv);
  }
}
