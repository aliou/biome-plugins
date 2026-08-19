interface Command {
  (argv: string[]): number;
}

class Shell {
  status = 0;
  run(command: Command, argv: string[]): number {
    return command(argv);
  }
}
