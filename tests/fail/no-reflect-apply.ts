interface Command {
  (argv: string[]): number;
}

class Shell {
  status = 0;
  run(command: Command, argv: string[]): number {
    return Reflect.apply(command, this, argv);
  }
}
