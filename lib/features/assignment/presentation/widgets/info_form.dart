import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../domain/student_info.dart';
import '../providers/assignment_provider.dart';

class InfoForm extends ConsumerWidget {
  const InfoForm({super.key});

  // Premium palette (matches other screens)
  static const _primaryStart = Color(0xFF6366F1);
  static const _primaryEnd = Color(0xFF8B5CF6);
  static const _accent = Color(0xFF06B6D4);
  static const _gold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final d = ref.watch(assignmentProvider);
    final n = ref.read(assignmentProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget pair(Widget a, Widget b) => Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ═══════════════════════════════════════════════════════
        // INSTITUTION
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('secInstitution'),
          children: [
            AppTextField(
              label: s.t('institution'),
              value: d.institutionName,
              onChanged: n.setInstitutionName,
            ),
            AppTextField(
              label: s.t('department'),
              value: d.department,
              onChanged: n.setDepartment,
            ),
            const SizedBox(height: 4),
            _LogoPicker(
              s: s,
              isDark: isDark,
              logoBytes: d.logoBytes,
              onPick: () => _pickLogo(ref),
              onRemove: n.clearLogo,
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // COURSE & ASSIGNMENT
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('secCourse'),
          children: [
            pair(
              AppTextField(
                label: s.t('courseTitle'),
                value: d.courseTitle,
                onChanged: n.setCourseTitle,
              ),
              AppTextField(
                label: s.t('courseCode'),
                value: d.courseCode,
                onChanged: n.setCourseCode,
              ),
            ),
            AppTextField(
              label: s.t('assignmentTitle'),
              value: d.assignmentTitle,
              maxLines: 2,
              onChanged: n.setAssignmentTitle,
            ),
            AppTextField(
              label: s.t('assignmentNo'),
              value: d.assignmentNo,
              onChanged: n.setAssignmentNo,
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // TEACHER
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('secTeacher'),
          children: [
            AppTextField(
              label: s.t('teacherName'),
              value: d.submittedTo.name,
              onChanged: n.setTeacherName,
            ),
            pair(
              AppTextField(
                label: s.t('designation'),
                value: d.submittedTo.designation,
                onChanged: n.setTeacherDesignation,
              ),
              AppTextField(
                label: s.t('department'),
                value: d.submittedTo.department,
                onChanged: n.setTeacherDepartment,
              ),
            ),
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // STUDENT
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('secStudent'),
          children: [
            pair(
              AppTextField(
                label: s.t('studentName'),
                value: d.submittedBy.name,
                onChanged: n.setStudentName,
              ),
              AppTextField(
                label: s.t('studentId'),
                value: d.submittedBy.studentId,
                onChanged: n.setStudentId,
              ),
            ),
            pair(
              AppTextField(
                label: s.t('roll'),
                value: d.submittedBy.roll,
                onChanged: (v) => n.update(
                  (x) => x.copyWith(
                    submittedBy: x.submittedBy.copyWith(roll: v),
                  ),
                ),
              ),
              AppTextField(
                label: s.t('regNo'),
                value: d.submittedBy.regNo,
                onChanged: (v) => n.update(
                  (x) => x.copyWith(
                    submittedBy: x.submittedBy.copyWith(regNo: v),
                  ),
                ),
              ),
            ),
            pair(
              AppTextField(
                label: s.t('semester'),
                value: d.submittedBy.semester,
                onChanged: (v) => n.update(
                  (x) => x.copyWith(
                    submittedBy: x.submittedBy.copyWith(semester: v),
                  ),
                ),
              ),
              AppTextField(
                label: s.t('session'),
                value: d.submittedBy.session,
                onChanged: (v) => n.update(
                  (x) => x.copyWith(
                    submittedBy: x.submittedBy.copyWith(session: v),
                  ),
                ),
              ),
            ),
            AppTextField(
              label: s.t('batch'),
              value: d.submittedBy.batch,
              onChanged: (v) => n.update(
                (x) => x.copyWith(
                  submittedBy: x.submittedBy.copyWith(batch: v),
                ),
              ),
            ),

            // ── Group toggle (premium switch card) ──
            const SizedBox(height: 4),
            _GroupToggle(
              s: s,
              isDark: isDark,
              value: d.isGroup,
              onChanged: n.setGroupMode,
            ),

            // ── Group members ──
            if (d.isGroup) ...[
              const SizedBox(height: 8),
              for (var i = 0; i < d.groupMembers.length; i++)
                _MemberEditor(
                  index: i,
                  member: d.groupMembers[i],
                  total: d.groupMembers.length,
                  onMoveUp: i > 0 ? () => n.moveMemberUp(i) : null,
                  onMoveDown: i < d.groupMembers.length - 1
                      ? () => n.moveMemberDown(i)
                      : null,
                ),
              const SizedBox(height: 8),
              _AddMemberButton(
                s: s,
                isDark: isDark,
                onPressed: n.addMember,
              ),
            ],
          ],
        ),

        // ═══════════════════════════════════════════════════════
        // DATE & NOTE
        // ═══════════════════════════════════════════════════════
        SectionCard(
          title: s.t('secOther'),
          children: [
            _DatePickerRow(
              s: s,
              isDark: isDark,
              date: d.submissionDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: d.submissionDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) n.setSubmissionDate(picked);
              },
            ),
            AppTextField(
              label: s.t('note'),
              value: d.note,
              maxLines: 2,
              onChanged: n.setNote,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickLogo(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes != null) {
      ref.read(assignmentProvider.notifier).setLogo(bytes);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// LOGO PICKER — premium card
// ═══════════════════════════════════════════════════════════════
class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.s,
    required this.isDark,
    required this.logoBytes,
    required this.onPick,
    required this.onRemove,
  });

  final AppStrings s;
  final bool isDark;
  final dynamic logoBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoBytes != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          // Preview box
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: hasLogo
                  ? null
                  : LinearGradient(
                      colors: [
                        InfoForm._primaryStart.withOpacity(0.12),
                        InfoForm._primaryEnd.withOpacity(0.06),
                      ],
                    ),
              color: hasLogo ? Colors.white : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: InfoForm._primaryStart
                    .withOpacity(hasLogo ? 0.3 : 0.2),
              ),
            ),
            child: hasLogo
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.memory(logoBytes!,
                        fit: BoxFit.cover, width: 52, height: 52),
                  )
                : Icon(
                    Icons.image_outlined,
                    color: InfoForm._primaryStart.withOpacity(0.7),
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),

          // Label + action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasLogo ? 'Logo attached' : s.t('uploadLogo'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLogo ? 'Tap remove to change' : 'PNG, JPG, or SVG',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (hasLogo)
            IconButton(
              tooltip: s.t('removeLogo'),
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, size: 20),
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
            ),
          IconButton(
            tooltip: s.t('uploadLogo'),
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: InfoForm._primaryStart,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GROUP TOGGLE — premium switch card
// ═══════════════════════════════════════════════════════════════
class _GroupToggle extends StatelessWidget {
  const _GroupToggle({
    required this.s,
    required this.isDark,
    required this.value,
    required this.onChanged,
  });

  final AppStrings s;
  final bool isDark;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: value
            ? LinearGradient(
                colors: [
                  InfoForm._primaryStart.withOpacity(0.10),
                  InfoForm._primaryEnd.withOpacity(0.05),
                ],
              )
            : null,
        color: value
            ? null
            : (isDark
                ? Colors.white.withOpacity(0.02)
                : Colors.black.withOpacity(0.015)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? InfoForm._primaryStart.withOpacity(0.35)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05)),
          width: value ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: value
                  ? const LinearGradient(
                      colors: [InfoForm._primaryStart, InfoForm._primaryEnd],
                    )
                  : null,
              color: value
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04)),
              borderRadius: BorderRadius.circular(10),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color:
                            InfoForm._primaryStart.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 16,
              color: value
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withOpacity(0.55)
                      : Colors.black.withOpacity(0.5)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('group'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  value
                      ? 'Multiple students will be listed'
                      : 'Single student submission',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: InfoForm._primaryStart,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEMBER EDITOR — with reorder + delete
// ═══════════════════════════════════════════════════════════════
class _MemberEditor extends ConsumerWidget {
  const _MemberEditor({
    required this.index,
    required this.member,
    required this.total,
    this.onMoveUp,
    this.onMoveDown,
  });

  final int index;
  final StudentInfo member;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final n = ref.read(assignmentProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.025)
            : Colors.black.withOpacity(0.015),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with badge + actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      InfoForm._primaryStart,
                      InfoForm._primaryEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${s.t('member')} ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),

              // Move up
              if (onMoveUp != null)
                _MiniIconButton(
                  icon: Icons.keyboard_arrow_up_rounded,
                  onTap: onMoveUp!,
                  tooltip: 'Move up',
                ),
              // Move down
              if (onMoveDown != null)
                _MiniIconButton(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onTap: onMoveDown!,
                  tooltip: 'Move down',
                ),
              const SizedBox(width: 4),
              // Delete
              _MiniIconButton(
                icon: Icons.close_rounded,
                onTap: () => n.removeMember(index),
                tooltip: 'Remove',
                danger: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Name
          AppTextField(
            label: s.t('studentName'),
            value: member.name,
            onChanged: (v) =>
                n.updateMember(index, member.copyWith(name: v)),
          ),
          const SizedBox(height: 8),

          // ID + Roll
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: s.t('studentId'),
                  value: member.studentId,
                  onChanged: (v) => n.updateMember(
                    index,
                    member.copyWith(studentId: v),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  label: s.t('roll'),
                  value: member.roll,
                  onChanged: (v) => n.updateMember(
                    index,
                    member.copyWith(roll: v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MINI ICON BUTTON
// ═══════════════════════════════════════════════════════════════
class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = danger
        ? const Color(0xFFEF4444)
        : (isDark ? Colors.white : Colors.black87);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ADD MEMBER BUTTON
// ═══════════════════════════════════════════════════════════════
class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({
    required this.s,
    required this.isDark,
    required this.onPressed,
  });

  final AppStrings s;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        label: Text(s.t('addMember')),
        style: OutlinedButton.styleFrom(
          foregroundColor: InfoForm._primaryStart,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: InfoForm._primaryStart
                .withOpacity(isDark ? 0.5 : 0.35),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DATE PICKER ROW
// ═══════════════════════════════════════════════════════════════
class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.s,
    required this.isDark,
    required this.date,
    required this.onTap,
  });

  final AppStrings s;
  final bool isDark;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted =
        DateFormat('d MMMM yyyy', s.isBangla ? 'bn' : 'en').format(date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      InfoForm._primaryStart,
                      InfoForm._primaryEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: InfoForm._primaryStart.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.t('date'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_calendar_rounded,
                size: 18,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}