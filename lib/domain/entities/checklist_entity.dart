class ChecklistEntity {
  final int? id;
  final int noteId;
  final String text;
  final bool isCompleted;
  final int sortOrder;

  const ChecklistEntity({
    this.id,
    required this.noteId,
    required this.text,
    this.isCompleted = false,
    this.sortOrder = 0,
  });

  ChecklistEntity copyWith({
    int? id,
    int? noteId,
    String? text,
    bool? isCompleted,
    int? sortOrder,
  }) {
    return ChecklistEntity(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  int get completionPercentage {
    // This is calculated at the note level, not item level
    return isCompleted ? 100 : 0;
  }
}
