enum PowerAction {
  start,
  stop,
  restart,
  kill
}

extension PowerActionExtension on PowerAction {
  String get apiValue {
    switch (this) {
      case PowerAction.start:
        return 'start';
      case PowerAction.stop:
        return 'stop';
      case PowerAction.restart:
        return 'restart';
      case PowerAction.kill:
        return 'kill';
    }
  }

  String get displayLabel {
    switch (this) {
      case PowerAction.start:
        return 'Start';
      case PowerAction.stop:
        return 'Stop';
      case PowerAction.restart:
        return 'Restart';
      case PowerAction.kill:
        return 'Kill';
    }
  }
}
