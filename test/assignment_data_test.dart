import 'package:assignx/features/assignment/domain/assignment_data.dart';
import 'package:assignx/features/assignment/domain/student_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AssignmentData survives a JSON round trip', () {
    final original = AssignmentData.empty().copyWith(
      institutionName: 'Test University',
      courseCode: 'CSE-101',
      isGroup: true,
      groupMembers: const [StudentInfo(name: 'Rafi', studentId: '123')],
    );

    final restored = AssignmentData.fromJson(original.toJson());

    expect(restored.institutionName, 'Test University');
    expect(restored.courseCode, 'CSE-101');
    expect(restored.groupMembers.single.name, 'Rafi');
  });
}