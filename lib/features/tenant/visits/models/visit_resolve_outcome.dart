/// Terminal burn outcomes. Wire names match `VisitResolveOutcome` on the API
/// (`JsonStringEnumConverter` → "Completed" / "NoShow").
enum VisitResolveOutcome {
  completed('Completed', 'Completed'),
  noShow('NoShow', 'No-show');

  const VisitResolveOutcome(this.wireName, this.label);

  final String wireName;
  final String label;
}
