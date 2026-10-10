/// A single student's information. Pure Dart: no UI code here.
class StudentInfo {
  const StudentInfo({
    this.name = '',
    this.studentId = '',
    this.roll = '',
    this.regNo = '',
    this.semester = '',
    this.session = '',
    this.batch = '',
  });

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════
  final String name;
  final String studentId;
  final String roll;
  final String regNo;
  final String semester;
  final String session;
  final String batch;

  // ═══════════════════════════════════════════════════════════
  // FACTORIES
  // ═══════════════════════════════════════════════════════════

  /// Empty student — useful as a default for group members.
  factory StudentInfo.empty() => const StudentInfo();

  // ═══════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ═══════════════════════════════════════════════════════════

  /// True when every field is empty.
  bool get isEmpty =>
      name.trim().isEmpty &&
      studentId.trim().isEmpty &&
      roll.trim().isEmpty &&
      regNo.trim().isEmpty &&
      semester.trim().isEmpty &&
      session.trim().isEmpty &&
      batch.trim().isEmpty;

  /// Inverse of [isEmpty].
  bool get isNotEmpty => !isEmpty;

  /// True when the minimum fields for a cover are filled (name + ID).
  bool get isComplete =>
      name.trim().isNotEmpty && studentId.trim().isNotEmpty;

  /// Count of non-empty fields (0–7).
  int get filledFieldCount => [
        name,
        studentId,
        roll,
        regNo,
        semester,
        session,
        batch,
      ].where((v) => v.trim().isNotEmpty).length;

  /// Fraction (0.0 – 1.0) of fields filled.
  double get completeness => filledFieldCount / 7;

  /// Short display label — name or fallback.
  String get displayName =>
      name.trim().isEmpty ? 'Unnamed Student' : name.trim();

  /// Compact summary line, e.g. `"Rahim · ID 12345"`.
  String get summary {
    final parts = <String>[];
    if (name.trim().isNotEmpty) parts.add(name.trim());
    if (studentId.trim().isNotEmpty) parts.add('ID ${studentId.trim()}');
    if (roll.trim().isNotEmpty) parts.add('Roll ${roll.trim()}');
    return parts.isEmpty ? '(empty student)' : parts.join(' · ');
  }

  /// Initials for avatar placeholders (max 2 chars).
  String get initials {
    final n = name.trim();
    if (n.isEmpty) return '?';
    final words = n.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.characters.take(1).toString().toUpperCase();
    }
    return (words.first.characters.take(1).toString() +
            words.last.characters.take(1).toString())
        .toUpperCase();
  }

  // ═══════════════════════════════════════════════════════════
  // COPY-WITH
  // ═══════════════════════════════════════════════════════════
  StudentInfo copyWith({
    String? name,
    String? studentId,
    String? roll,
    String? regNo,
    String? semester,
    String? session,
    String? batch,
  }) {
    return StudentInfo(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      roll: roll ?? this.roll,
      regNo: regNo ?? this.regNo,
      semester: semester ?? this.semester,
      session: session ?? this.session,
      batch: batch ?? this.batch,
    );
  }

  /// Returns a copy with every field trimmed.
  StudentInfo trimmed() => StudentInfo(
        name: name.trim(),
        studentId: studentId.trim(),
        roll: roll.trim(),
        regNo: regNo.trim(),
        semester: semester.trim(),
        session: session.trim(),
        batch: batch.trim(),
      );

  /// Clears all fields — useful for "reset member" actions.
  StudentInfo cleared() => const StudentInfo();

  // ═══════════════════════════════════════════════════════════
  // SERIALIZATION
  // ═══════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() => {
        'name': name,
        'studentId': studentId,
        'roll': roll,
        'regNo': regNo,
        'semester': semester,
        'session': session,
        'batch': batch,
      };

  factory StudentInfo.fromJson(Map<String, dynamic> j) => StudentInfo(
        name: j['name'] as String? ?? '',
        studentId: j['studentId'] as String? ?? '',
        roll: j['roll'] as String? ?? '',
        regNo: j['regNo'] as String? ?? '',
        semester: j['semester'] as String? ?? '',
        session: j['session'] as String? ?? '',
        batch: j['batch'] as String? ?? '',
      );

  // ═══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ═══════════════════════════════════════════════════════════
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentInfo &&
        other.name == name &&
        other.studentId == studentId &&
        other.roll == roll &&
        other.regNo == regNo &&
        other.semester == semester &&
        other.session == session &&
        other.batch == batch;
  }

  @override
  int get hashCode => Object.hash(
        name,
        studentId,
        roll,
        regNo,
        semester,
        session,
        batch,
      );

  @override
  String toString() => 'StudentInfo($summary)';
}

// ═══════════════════════════════════════════════════════════════
// CHARACTERS HELPER — needed for initials (Dart 3+)
// ═══════════════════════════════════════════════════════════════
extension _CharactersHelper on String {
  Iterable<String> get characters sync* {
    for (final rune in runes) {
      yield String.fromCharCode(rune);
    }
  }
}