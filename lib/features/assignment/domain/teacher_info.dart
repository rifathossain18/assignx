/// A teacher's information. Pure Dart: no UI code here.
class TeacherInfo {
  const TeacherInfo({
    this.name = '',
    this.designation = '',
    this.department = '',
  });

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════
  final String name;
  final String designation;
  final String department;

  // ═══════════════════════════════════════════════════════════
  // FACTORIES
  // ═══════════════════════════════════════════════════════════

  /// Empty teacher — useful as a default.
  factory TeacherInfo.empty() => const TeacherInfo();

  // ═══════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ═══════════════════════════════════════════════════════════

  /// True when every field is empty.
  bool get isEmpty =>
      name.trim().isEmpty &&
      designation.trim().isEmpty &&
      department.trim().isEmpty;

  /// Inverse of [isEmpty].
  bool get isNotEmpty => !isEmpty;

  /// True when the minimum field for a cover is filled (name).
  bool get isComplete => name.trim().isNotEmpty;

  /// Count of non-empty fields (0–3).
  int get filledFieldCount =>
      [name, designation, department].where((v) => v.trim().isNotEmpty).length;

  /// Fraction (0.0 – 1.0) of fields filled.
  double get completeness => filledFieldCount / 3;

  /// Short display label — name or fallback.
  String get displayName =>
      name.trim().isEmpty ? 'Unnamed Teacher' : name.trim();

  /// Compact summary line, e.g. `"Dr. Karim · Professor"`.
  String get summary {
    final parts = <String>[];
    if (name.trim().isNotEmpty) parts.add(name.trim());
    if (designation.trim().isNotEmpty) parts.add(designation.trim());
    if (department.trim().isNotEmpty) parts.add(department.trim());
    return parts.isEmpty ? '(empty teacher)' : parts.join(' · ');
  }

  /// Initials for avatar placeholders (max 2 chars).
  /// Handles honorific prefixes like "Dr.", "Prof.", "Mr." automatically.
  String get initials {
    final n = name.trim();
    if (n.isEmpty) return '?';

    // Strip common honorifics
    const honorifics = {
      'dr',
      'dr.',
      'prof',
      'prof.',
      'professor',
      'mr',
      'mr.',
      'mrs',
      'mrs.',
      'ms',
      'ms.',
      'md',
      'md.',
      'mst',
      'mst.',
    };
    final words = n
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !honorifics.contains(w.toLowerCase()))
        .toList();

    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.characters.take(1).toString().toUpperCase();
    }
    return (words.first.characters.take(1).toString() +
            words.last.characters.take(1).toString())
        .toUpperCase();
  }

  /// Formatted display line, e.g. `"Prof. Karim — Professor, CSE"`.
  /// Omits empty parts gracefully.
  String get fullDisplay {
    final n = name.trim();
    final d = designation.trim();
    final dept = department.trim();
    if (n.isEmpty && d.isEmpty && dept.isEmpty) return '(empty teacher)';
    if (n.isEmpty) return [d, dept].where((e) => e.isNotEmpty).join(', ');
    if (d.isEmpty && dept.isEmpty) return n;

    final tail = [d, dept].where((e) => e.isNotEmpty).join(', ');
    return tail.isEmpty ? n : '$n — $tail';
  }

  // ═══════════════════════════════════════════════════════════
  // COPY-WITH
  // ═══════════════════════════════════════════════════════════
  TeacherInfo copyWith({
    String? name,
    String? designation,
    String? department,
  }) {
    return TeacherInfo(
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
    );
  }

  /// Returns a copy with every field trimmed.
  TeacherInfo trimmed() => TeacherInfo(
        name: name.trim(),
        designation: designation.trim(),
        department: department.trim(),
      );

  /// Clears all fields — useful for "reset" actions.
  TeacherInfo cleared() => const TeacherInfo();

  // ═══════════════════════════════════════════════════════════
  // SERIALIZATION
  // ═══════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() => {
        'name': name,
        'designation': designation,
        'department': department,
      };

  factory TeacherInfo.fromJson(Map<String, dynamic> j) => TeacherInfo(
        name: j['name'] as String? ?? '',
        designation: j['designation'] as String? ?? '',
        department: j['department'] as String? ?? '',
      );

  // ═══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ═══════════════════════════════════════════════════════════
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeacherInfo &&
        other.name == name &&
        other.designation == designation &&
        other.department == department;
  }

  @override
  int get hashCode => Object.hash(name, designation, department);

  @override
  String toString() => 'TeacherInfo($summary)';
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