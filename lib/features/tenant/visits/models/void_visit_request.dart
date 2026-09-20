class VoidVisitRequest {
  const VoidVisitRequest({this.note = ''});

  final String note;

  Map<String, dynamic> toJson() => {
        if (note.trim().isNotEmpty) 'note': note.trim(),
      };
}
