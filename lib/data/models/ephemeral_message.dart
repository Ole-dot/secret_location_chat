/// Shared contract for messages that self-destruct after [expiresAt].
mixin EphemeralMessage {
  String get id;
  DateTime get expiresAt;

  bool get isAlive => DateTime.now().isBefore(expiresAt);

  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
