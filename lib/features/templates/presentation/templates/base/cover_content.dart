import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_fonts.dart';
import '../../../../assignment/domain/student_info.dart';
import '../../../domain/cover_args.dart';
import '../../../domain/template_config.dart';

/// The shared text layout of every cover.
///
/// Uses BUNDLED fonts — instant change, always visible.
class CoverContent extends StatelessWidget {
  const CoverContent({
    super.key,
    required this.args,
    this.textColor = const Color(0xFF1F2937),
    this.accentColor,
    this.showCrestPlaceholder = false,
  });

  final CoverArgs args;
  final Color textColor;
  final Color? accentColor;
  final bool showCrestPlaceholder;

  @override
  Widget build(BuildContext context) {
    final d = args.data;
    final c = args.config;
    final s = args.strings;
    final accent = accentColor ?? c.primaryColor;
    final isCenter = c.alignment == ContentAlign.center;
    final cross =
        isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final align = isCenter ? TextAlign.center : TextAlign.left;
    final gap = c.compact ? 18.0 : 38.0;
    double ls(double v) => s.isBangla ? 0 : v;

    // ═══════════════════════════════════════════════════════════
    // STYLE — bundled fonts via AppFonts
    // ═══════════════════════════════════════════════════════════
    TextStyle st({
      required double size,
      FontWeight w = FontWeight.w400,
      Color? color,
      double? spacing,
      double? h,
      FontStyle? fs,
    }) {
      return AppFonts.style(
        c.fontFamily,
        size: size,
        weight: w,
        color: color ?? textColor,
        letterSpacing: spacing,
        height: h ?? 1.35,
        fontStyle: fs,
      );
    }

    String v(String value, String placeholderKey) =>
        value.trim().isEmpty ? s.t(placeholderKey) : value.trim();

    // ── HEADER ──
    Widget? logo;
    if (d.logoBytes != null) {
      logo = Image.memory(d.logoBytes!, height: 78, fit: BoxFit.contain);
    } else if (showCrestPlaceholder) {
      logo = Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withOpacity(0.08),
          border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
        ),
        child: Icon(Icons.account_balance_rounded, size: 32, color: accent),
      );
    }

    final titles = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        Text(
          v(d.institutionName, 'phInstitution'),
          textAlign: align,
          style: st(
            size: 24,
            w: FontWeight.w800,
            color: accent,
            h: 1.25,
            spacing: ls(-0.3),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          v(d.department, 'phDepartment'),
          textAlign: align,
          style: st(
            size: 13.5,
            w: FontWeight.w500,
            color: textColor.withOpacity(0.72),
            h: 1.35,
          ),
        ),
      ],
    );

    final Widget header;
    if (logo != null && c.logoPosition == LogoPosition.side) {
      header = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logo,
          const SizedBox(width: 18),
          Expanded(child: titles),
        ],
      );
    } else {
      header = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: cross,
        children: [
          if (logo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: logo,
            ),
          titles,
        ],
      );
    }

    // ── TITLE ──
    final label = s.t('assignment').toUpperCase() +
        (d.assignmentNo.trim().isNotEmpty
            ? '   ${s.t('no')} ${d.assignmentNo.trim()}'
            : '');
    final course = v(d.courseTitle, 'phCourse') +
        (d.courseCode.trim().isNotEmpty ? ' (${d.courseCode.trim()})' : '');

    final labelChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: accent.withOpacity(0.28), width: 1),
      ),
      child: Text(
        label,
        style: st(
          size: 11,
          w: FontWeight.w800,
          color: accent,
          spacing: ls(2.2),
        ),
      ),
    );

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        labelChip,
        const SizedBox(height: 16),
        Text(
          v(d.assignmentTitle, 'phTitle'),
          textAlign: align,
          style: st(
            size: 30,
            w: FontWeight.w800,
            h: 1.25,
            spacing: ls(-0.4),
          ),
        ),
        const SizedBox(height: 14),
        Container(width: 60, height: 3, color: accent),
        const SizedBox(height: 14),
        Text(
          course,
          textAlign: align,
          style: st(
            size: 14,
            w: FontWeight.w500,
            color: textColor.withOpacity(0.85),
            h: 1.35,
          ),
        ),
      ],
    );

    // ── PEOPLE ──
    Widget line(String labelText, String value) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          labelText.isEmpty ? value : '$labelText: $value',
          style: st(
            size: 11.5,
            w: FontWeight.w500,
            color: textColor.withOpacity(0.92),
            h: 1.4,
          ),
        ),
      );
    }

    Widget card(String title, IconData icon, List<Widget> kids) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accent.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: accent),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: st(
                      size: 10.5,
                      w: FontWeight.w800,
                      color: accent,
                      spacing: ls(1.8),
                      h: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...kids,
          ],
        ),
      );
    }

    List<Widget> studentLines(StudentInfo m) => [
          Text(
            v(m.name, 'phName'),
            style: st(
              size: 13,
              w: FontWeight.w700,
              h: 1.3,
              color: textColor,
            ),
          ),
          line(s.t('studentId'), v(m.studentId, 'phId')),
          if (m.roll.trim().isNotEmpty) line(s.t('roll'), m.roll.trim()),
          if (m.regNo.trim().isNotEmpty) line(s.t('regNo'), m.regNo.trim()),
          if (m.semester.trim().isNotEmpty)
            line(s.t('semester'), m.semester.trim()),
          if (m.session.trim().isNotEmpty)
            line(s.t('session'), m.session.trim()),
          if (m.batch.trim().isNotEmpty) line(s.t('batch'), m.batch.trim()),
        ];

    final teacher = card(
      s.t('submittedTo'),
      Icons.school_rounded,
      [
        Text(
          v(d.submittedTo.name, 'phTeacher'),
          style: st(
            size: 13,
            w: FontWeight.w700,
            h: 1.3,
            color: textColor,
          ),
        ),
        if (d.submittedTo.designation.trim().isNotEmpty)
          line('', d.submittedTo.designation.trim()),
        if (d.submittedTo.department.trim().isNotEmpty)
          line('', d.submittedTo.department.trim()),
      ],
    );

    final students = d.allStudents;
    final by = card(
      s.t('submittedBy'),
      Icons.person_rounded,
      [
        for (var i = 0; i < students.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          ...studentLines(students[i]),
        ],
      ],
    );

    final people = SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: teacher),
          const SizedBox(width: 14),
          Expanded(child: by),
        ],
      ),
    );

    // ── FOOTER ──
    final dateText = DateFormat('d MMMM yyyy', s.isBangla ? 'bn' : 'en')
        .format(d.submissionDate);

    final footer = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        Text(
          '${s.t('dateLabel')}: $dateText',
          textAlign: align,
          style: st(size: 12, w: FontWeight.w600, h: 1.35),
        ),
        if (d.note.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            d.note.trim(),
            textAlign: align,
            style: st(
              size: 11,
              fs: FontStyle.italic,
              color: textColor.withOpacity(0.8),
              h: 1.45,
            ),
          ),
        ],
      ],
    );

    // ── FINAL LAYOUT ──
    return LayoutBuilder(
      builder: (context, box) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: box.maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: cross,
            children: [
              header,
              SizedBox(height: gap),
              titleBlock,
              SizedBox(height: gap),
              people,
              SizedBox(height: gap),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}