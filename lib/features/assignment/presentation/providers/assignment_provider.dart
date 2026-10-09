import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/assignment_data.dart';
import '../../domain/student_info.dart';

class AssignmentNotifier extends Notifier<AssignmentData> {
  @override
  AssignmentData build() => AssignmentData.empty();

  // ═══════════════════════════════════════════════════════════
  // CORE OPERATIONS (existing — unchanged)
  // ═══════════════════════════════════════════════════════════

  /// Apply a transformation to the current state.
  void update(AssignmentData Function(AssignmentData current) change) {
    state = change(state);
  }

  /// Replace the entire data (used by draft load / JSON restore).
  void replace(AssignmentData data) => state = data;

  // ═══════════════════════════════════════════════════════════
  // RESET / CLEAR
  // ═══════════════════════════════════════════════════════════

  /// Reset to a fresh empty state (fresh submission date).
  void reset() => state = AssignmentData.empty();

  /// Clear everything but preserve the current submission date.
  void clearContent() => state = AssignmentData.empty().copyWith(
        submissionDate: state.submissionDate,
      );

  // ═══════════════════════════════════════════════════════════
  // GROUP MODE
  // ═══════════════════════════════════════════════════════════

  /// Enable/disable group mode. Disabling clears all members safely.
  void setGroupMode(bool enabled) {
    state = state.withGroupMode(enabled);
  }

  /// Toggle group mode on/off.
  void toggleGroupMode() => setGroupMode(!state.isGroup);

  // ═══════════════════════════════════════════════════════════
  // MEMBER OPERATIONS (existing + hardened)
  // ═══════════════════════════════════════════════════════════

  /// Add a new empty member. No-ops if group mode is off.
  void addMember() {
    if (!state.isGroup) return;
    state = state.copyWith(
      groupMembers: [...state.groupMembers, const StudentInfo()],
    );
  }

  /// Add a pre-filled member. No-ops if group mode is off.
  void addMemberWith(StudentInfo member) {
    if (!state.isGroup) return;
    state = state.copyWith(
      groupMembers: [...state.groupMembers, member],
    );
  }

  /// Replace a member at [index]. Safe against out-of-range indices.
  void updateMember(int index, StudentInfo member) {
    if (index < 0 || index >= state.groupMembers.length) return;
    final list = [...state.groupMembers];
    list[index] = member;
    state = state.copyWith(groupMembers: list);
  }

  /// Remove a member at [index]. Safe against out-of-range indices.
  void removeMember(int index) {
    if (index < 0 || index >= state.groupMembers.length) return;
    final list = [...state.groupMembers]..removeAt(index);
    state = state.copyWith(groupMembers: list);
  }

  /// Remove all group members at once (keeps group mode on).
  void clearMembers() {
    state = state.copyWith(groupMembers: const []);
  }

  /// Duplicate a member at [index] (convenient for similar rows).
  void duplicateMember(int index) {
    if (index < 0 || index >= state.groupMembers.length) return;
    final copy = state.groupMembers[index].copyWith(name: '');
    final list = [...state.groupMembers]..insert(index + 1, copy);
    state = state.copyWith(groupMembers: list);
  }

  /// Move a member up by one position.
  void moveMemberUp(int index) {
    if (index <= 0 || index >= state.groupMembers.length) return;
    final list = [...state.groupMembers];
    final item = list.removeAt(index);
    list.insert(index - 1, item);
    state = state.copyWith(groupMembers: list);
  }

  /// Move a member down by one position.
  void moveMemberDown(int index) {
    if (index < 0 || index >= state.groupMembers.length - 1) return;
    final list = [...state.groupMembers];
    final item = list.removeAt(index);
    list.insert(index + 1, item);
    state = state.copyWith(groupMembers: list);
  }

  // ═══════════════════════════════════════════════════════════
  // CONVENIENCE SETTERS
  // ═══════════════════════════════════════════════════════════

  void setInstitutionName(String value) =>
      state = state.copyWith(institutionName: value);

  void setDepartment(String value) =>
      state = state.copyWith(department: value);

  void setCourseTitle(String value) =>
      state = state.copyWith(courseTitle: value);

  void setCourseCode(String value) =>
      state = state.copyWith(courseCode: value);

  void setAssignmentTitle(String value) =>
      state = state.copyWith(assignmentTitle: value);

  void setAssignmentNo(String value) =>
      state = state.copyWith(assignmentNo: value);

  void setNote(String value) => state = state.copyWith(note: value);

  void setSubmissionDate(DateTime date) =>
      state = state.copyWith(submissionDate: date);

  /// Set (or clear) the institution logo.
  void setLogo(dynamic bytes) {
    if (bytes == null) {
      state = state.copyWith(clearLogo: true);
    } else {
      state = state.copyWith(logoBytes: bytes);
    }
  }

  /// Remove the logo (convenience wrapper).
  void clearLogo() => state = state.copyWith(clearLogo: true);

  // ── Teacher convenience ──
  void setTeacherName(String value) =>
      state = state.copyWith(
        submittedTo: state.submittedTo.copyWith(name: value),
      );

  void setTeacherDesignation(String value) =>
      state = state.copyWith(
        submittedTo: state.submittedTo.copyWith(designation: value),
      );

  void setTeacherDepartment(String value) =>
      state = state.copyWith(
        submittedTo: state.submittedTo.copyWith(department: value),
      );

  void replaceTeacher(dynamic teacher) => state = state.copyWith(
        submittedTo: teacher,
      );

  // ── Primary student convenience ──
  void setStudentName(String value) =>
      state = state.copyWith(
        submittedBy: state.submittedBy.copyWith(name: value),
      );

  void setStudentId(String value) =>
      state = state.copyWith(
        submittedBy: state.submittedBy.copyWith(studentId: value),
      );

  void replaceStudent(StudentInfo student) =>
      state = state.copyWith(submittedBy: student);

  // ═══════════════════════════════════════════════════════════
  // BATCH OPERATIONS
  // ═══════════════════════════════════════════════════════════

  /// Trim every string field on the model before export / save.
  void trimAll() {
    state = state.copyWith(
      institutionName: state.institutionName.trim(),
      department: state.department.trim(),
      courseTitle: state.courseTitle.trim(),
      courseCode: state.courseCode.trim(),
      assignmentTitle: state.assignmentTitle.trim(),
      assignmentNo: state.assignmentNo.trim(),
      note: state.note.trim(),
      submittedTo: state.submittedTo.trimmed(),
      submittedBy: state.submittedBy.trimmed(),
      groupMembers: state.groupMembers.map((m) => m.trimmed()).toList(),
    );
  }

  /// Replace all group members at once (e.g. from a bulk paste).
  void setMembers(List<StudentInfo> members) {
    state = state.copyWith(groupMembers: List.unmodifiable(members));
  }
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER (unchanged signature)
// ═══════════════════════════════════════════════════════════════
final assignmentProvider =
    NotifierProvider<AssignmentNotifier, AssignmentData>(
  AssignmentNotifier.new,
);