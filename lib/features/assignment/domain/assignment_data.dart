import 'dart:typed_data';

import 'student_info.dart';
import 'teacher_info.dart';

/// All the information a user types in. Pure Dart: no UI code here.
class AssignmentData {
  AssignmentData({
    this.institutionName = '',
    this.logoBytes,
    this.department = '',
    this.courseTitle = '',
    this.courseCode = '',
    this.assignmentTitle = '',
    this.assignmentNo = '',
    this.submittedTo = const TeacherInfo(),
    this.submittedBy = const StudentInfo(),
    this.isGroup = false,
    this.groupMembers = const [],
    required this.submissionDate,
    this.note = '',
  });

  factory AssignmentData.empty() =>
      AssignmentData(submissionDate: DateTime.now());

  // ═══════════════════════════════════════════════════════════
  // FIELDS
  // ═══════════════════════════════════════════════════════════
  final String institutionName;
  final Uint8List? logoBytes;
  final String department;
  final String courseTitle;
  final String courseCode;
  final String assignmentTitle;
  final String assignmentNo;
  final TeacherInfo submittedTo;
  final StudentInfo submittedBy;
  final bool isGroup;
  final List<StudentInfo> groupMembers;
  final DateTime submissionDate;
  final String note;

  // ═══════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ═══════════════════════════════════════════════════════════

  /// The main student plus group members (when group mode is on).
  List<StudentInfo> get allStudents =>
      [submittedBy, if (isGroup) ...groupMembers];

  /// Total number of students (main + group members if enabled).
  int get totalStudents => isGroup ? 1 + groupMembers.length : 1;

  /// True when there is at least one non-empty field.
  bool get hasAnyContent =>
      institutionName.trim().isNotEmpty ||
      department.trim().isNotEmpty ||
      courseTitle.trim().isNotEmpty ||
      courseCode.trim().isNotEmpty ||
      assignmentTitle.trim().isNotEmpty ||
      assignmentNo.trim().isNotEmpty ||
      note.trim().isNotEmpty ||
      logoBytes != null ||
      submittedTo.name.trim().isNotEmpty ||
      submittedBy.name.trim().isNotEmpty ||
      groupMembers.isNotEmpty;

  /// True when the essential fields are filled (title + institution + student).
  bool get isReadyToExport =>
      institutionName.trim().isNotEmpty &&
      assignmentTitle.trim().isNotEmpty &&
      submittedBy.name.trim().isNotEmpty;

  /// Fraction (0.0 – 1.0) of essential fields filled.
  /// Useful for showing a progress bar in the editor.
  double get completeness {
    const fields = [
      'institutionName',
      'department',
      'courseTitle',
      'assignmentTitle',
      'assignmentNo',
      'submittedTo.name',
      'submittedBy.name',
    ];
    final filled = <String, bool>{
      'institutionName': institutionName.trim().isNotEmpty,
      'department': department.trim().isNotEmpty,
      'courseTitle': courseTitle.trim().isNotEmpty,
      'assignmentTitle': assignmentTitle.trim().isNotEmpty,
      'assignmentNo': assignmentNo.trim().isNotEmpty,
      'submittedTo.name': submittedTo.name.trim().isNotEmpty,
      'submittedBy.name': submittedBy.name.trim().isNotEmpty,
    };
    final count = filled.values.where((v) => v).length;
    return count / fields.length;
  }

  /// Human-friendly summary — useful for debugging and toasts.
  String get summary {
    final t = assignmentTitle.trim().isEmpty
        ? '(untitled)'
        : assignmentTitle.trim();
    final inst = institutionName.trim().isEmpty
        ? '(no institution)'
        : institutionName.trim();
    return '$t @ $inst · $totalStudents student(s)';
  }

  // ═══════════════════════════════════════════════════════════
  // COPY-WITH (enhanced)
  // ═══════════════════════════════════════════════════════════
  AssignmentData copyWith({
    String? institutionName,
    Uint8List? logoBytes,
    bool clearLogo = false,
    String? department,
    String? courseTitle,
    String? courseCode,
    String? assignmentTitle,
    String? assignmentNo,
    TeacherInfo? submittedTo,
    StudentInfo? submittedBy,
    bool? isGroup,
    List<StudentInfo>? groupMembers,
    DateTime? submissionDate,
    String? note,
  }) {
    return AssignmentData(
      institutionName: institutionName ?? this.institutionName,
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      department: department ?? this.department,
      courseTitle: courseTitle ?? this.courseTitle,
      courseCode: courseCode ?? this.courseCode,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      assignmentNo: assignmentNo ?? this.assignmentNo,
      submittedTo: submittedTo ?? this.submittedTo,
      submittedBy: submittedBy ?? this.submittedBy,
      isGroup: isGroup ?? this.isGroup,
      groupMembers: groupMembers ?? this.groupMembers,
      submissionDate: submissionDate ?? this.submissionDate,
      note: note ?? this.note,
    );
  }

  /// Creates a copy with group mode toggled. When disabling group mode,
  /// members are cleared automatically — prevents stale data leaking in.
  AssignmentData withGroupMode(bool enabled) {
    return copyWith(
      isGroup: enabled,
      groupMembers: enabled ? groupMembers : const [],
    );
  }

  /// Adds a member to the group. Silently no-ops if group mode is off.
  AssignmentData addMember(StudentInfo member) {
    if (!isGroup) return this;
    return copyWith(groupMembers: [...groupMembers, member]);
  }

  /// Removes a member by index. Silently no-ops if out of range.
  AssignmentData removeMemberAt(int index) {
    if (index < 0 || index >= groupMembers.length) return this;
    final next = [...groupMembers]..removeAt(index);
    return copyWith(groupMembers: next);
  }

  /// Replaces a member by index. Silently no-ops if out of range.
  AssignmentData replaceMemberAt(int index, StudentInfo member) {
    if (index < 0 || index >= groupMembers.length) return this;
    final next = [...groupMembers]..[index] = member;
    return copyWith(groupMembers: next);
  }

  // ═══════════════════════════════════════════════════════════
  // SERIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// The logo is intentionally not saved in drafts (keeps storage small).
  Map<String, dynamic> toJson() => {
        'institutionName': institutionName,
        'department': department,
        'courseTitle': courseTitle,
        'courseCode': courseCode,
        'assignmentTitle': assignmentTitle,
        'assignmentNo': assignmentNo,
        'submittedTo': submittedTo.toJson(),
        'submittedBy': submittedBy.toJson(),
        'isGroup': isGroup,
        'groupMembers': groupMembers.map((m) => m.toJson()).toList(),
        'submissionDate': submissionDate.toIso8601String(),
        'note': note,
      };

  factory AssignmentData.fromJson(Map<String, dynamic> j) {
    return AssignmentData(
      institutionName: j['institutionName'] as String? ?? '',
      department: j['department'] as String? ?? '',
      courseTitle: j['courseTitle'] as String? ?? '',
      courseCode: j['courseCode'] as String? ?? '',
      assignmentTitle: j['assignmentTitle'] as String? ?? '',
      assignmentNo: j['assignmentNo'] as String? ?? '',
      submittedTo: TeacherInfo.fromJson(
          Map<String, dynamic>.from(j['submittedTo'] as Map? ?? {})),
      submittedBy: StudentInfo.fromJson(
          Map<String, dynamic>.from(j['submittedBy'] as Map? ?? {})),
      isGroup: j['isGroup'] as bool? ?? false,
      groupMembers: ((j['groupMembers'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => StudentInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      submissionDate: DateTime.tryParse(
              j['submissionDate'] as String? ?? '') ??
          DateTime.now(),
      note: j['note'] as String? ?? '',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ═══════════════════════════════════════════════════════════
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AssignmentData &&
        other.institutionName == institutionName &&
        other.department == department &&
        other.courseTitle == courseTitle &&
        other.courseCode == courseCode &&
        other.assignmentTitle == assignmentTitle &&
        other.assignmentNo == assignmentNo &&
        other.submittedTo == submittedTo &&
        other.submittedBy == submittedBy &&
        other.isGroup == isGroup &&
        _listEquals(other.groupMembers, groupMembers) &&
        other.submissionDate == submissionDate &&
        other.note == note &&
        _bytesEquals(other.logoBytes, logoBytes);
  }

  @override
  int get hashCode => Object.hash(
        institutionName,
        department,
        courseTitle,
        courseCode,
        assignmentTitle,
        assignmentNo,
        submittedTo,
        submittedBy,
        isGroup,
        Object.hashAll(groupMembers),
        submissionDate,
        note,
        logoBytes == null ? null : Object.hashAll(logoBytes!),
      );

  @override
  String toString() => 'AssignmentData($summary)';

  // ── Internal helpers ──
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _bytesEquals(Uint8List? a, Uint8List? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}