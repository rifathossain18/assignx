import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Very small bilingual string table: key -> [English, বাংলা].
/// To add a language later, replace this with Flutter's gen-l10n.
class AppStrings {
  const AppStrings(this.isBangla);

  final bool isBangla;

  /// Translate a key. Returns the key itself if missing
  /// (and logs a warning in debug mode).
  String t(String key) {
    final v = _m[key];
    if (v == null) {
      assert(() {
        debugPrint('⚠️  [AppStrings] Missing key: "$key"');
        return true;
      }());
      return key;
    }
    return isBangla ? v[1] : v[0];
  }

  /// Translate with placeholder substitution.
  /// Example: `tArgs('greet', {'name': 'Rahim'})` with `'Hello {name}'`.
  String tArgs(String key, Map<String, String> args) {
    var out = t(key);
    args.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  /// Check if a key exists (useful for tests / validation).
  bool has(String key) => _m.containsKey(key);

  /// Current language code — 'bn' or 'en'.
  String get localeCode => isBangla ? 'bn' : 'en';

  /// Locale-style tag — 'bn-BD' or 'en-US'.
  String get localeTag => isBangla ? 'bn-BD' : 'en-US';

  /// Human-readable language name in its own script.
  String get languageName => isBangla ? 'বাংলা' : 'English';

  /// The opposite language name (for toggle labels).
  String get otherLanguageName => isBangla ? 'English' : 'বাংলা';

  // ═══════════════════════════════════════════════════════════
  // TRANSLATION TABLE
  // ═══════════════════════════════════════════════════════════
  static const Map<String, List<String>> _m = {
    // ── App / home ──
    'appName': ['AssignX', 'অ্যাসাইনএক্স'],
    'heroTitle': [
      'Create stunning cover pages in 2 minutes',
      '২ মিনিটে বানান প্রিমিয়াম কভার পেজ'
    ],
    'heroSub': [
      'Fill in the form once, pick a design, download the PDF. Free, no sign-up.',
      'একবার তথ্য দিন, ডিজাইন বাছুন, PDF নামান। ফ্রি, রেজিস্ট্রেশন লাগবে না।'
    ],
    'create': ['Create assignment', 'অ্যাসাইনমেন্ট তৈরি করুন'],
    'about': ['About', 'সম্পর্কে'],
    'aboutText': [
      'AssignX helps students create assignment cover pages quickly. Everything runs in your browser — nothing is sent to a server.',
      'অ্যাসাইনএক্স শিক্ষার্থীদের দ্রুত কভার পেজ বানাতে সাহায্য করে। সবকিছু আপনার ব্রাউজারেই চলে — কোনো তথ্য সার্ভারে যায় না।'
    ],
    'f1': ['8 ready-made templates', '৮টি রেডিমেড টেমপ্লেট'],
    'f2': ['Live A4 preview', 'লাইভ A4 প্রিভিউ'],
    'f3': ['PDF, PNG and print', 'PDF, PNG ও প্রিন্ট'],
    'f4': ['Free and private', 'ফ্রি ও প্রাইভেট'],

    // ── Editor ──
    'tabInfo': ['Info', 'তথ্য'],
    'tabTemplates': ['Templates', 'টেমপ্লেট'],
    'tabCustomize': ['Customize', 'কাস্টমাইজ'],
    'edit': ['Edit', 'এডিট'],
    'preview': ['Preview', 'প্রিভিউ'],
    'zoom': ['Zoom', 'জুম'],
    'export': ['Export', 'এক্সপোর্ট'],
    'downloadPdf': ['Download PDF', 'PDF ডাউনলোড'],
    'downloadPng': ['Download PNG', 'PNG ডাউনলোড'],
    'print': ['Print', 'প্রিন্ট'],
    'draft': ['Draft', 'ড্রাফট'],
    'saveDraft': ['Save draft', 'ড্রাফট সেভ'],
    'loadDraft': ['Load draft', 'ড্রাফট লোড'],
    'draftSaved': ['Draft saved', 'ড্রাফট সেভ হয়েছে'],
    'draftLoaded': ['Draft loaded', 'ড্রাফট লোড হয়েছে'],
    'noDraft': ['No saved draft found', 'কোনো সেভ করা ড্রাফট নেই'],
    'exportFailed': [
      'Export failed. Open the Preview and try again.',
      'এক্সপোর্ট হয়নি। প্রিভিউ খুলে আবার চেষ্টা করুন।'
    ],
    'exportDone': ['Export complete', 'এক্সপোর্ট সম্পন্ন'],

    // ── Form ──
    'secInstitution': ['Institution', 'প্রতিষ্ঠান'],
    'institution': ['Institution name', 'প্রতিষ্ঠানের নাম'],
    'uploadLogo': ['Upload logo', 'লোগো আপলোড'],
    'removeLogo': ['Remove logo', 'লোগো মুছুন'],
    'department': ['Department', 'বিভাগ'],
    'secCourse': ['Course & assignment', 'কোর্স ও অ্যাসাইনমেন্ট'],
    'courseTitle': ['Course title', 'কোর্সের নাম'],
    'courseCode': ['Course code', 'কোর্স কোড'],
    'assignmentTitle': ['Assignment title / topic', 'অ্যাসাইনমেন্টের শিরোনাম'],
    'assignmentNo': ['Assignment no.', 'অ্যাসাইনমেন্ট নম্বর'],
    'secTeacher': ['Teacher', 'শিক্ষক'],
    'teacherName': ['Teacher name', 'শিক্ষকের নাম'],
    'designation': ['Designation', 'পদবি'],
    'secStudent': ['Student', 'শিক্ষার্থী'],
    'studentName': ['Name', 'নাম'],
    'studentId': ['Student ID', 'স্টুডেন্ট আইডি'],
    'roll': ['Roll', 'রোল'],
    'regNo': ['Reg. no.', 'রেজি. নং'],
    'semester': ['Semester', 'সেমিস্টার'],
    'session': ['Session', 'সেশন'],
    'batch': ['Batch', 'ব্যাচ'],
    'group': ['Group assignment', 'গ্রুপ অ্যাসাইনমেন্ট'],
    'addMember': ['Add member', 'সদস্য যোগ করুন'],
    'member': ['Member', 'সদস্য'],
    'secOther': ['Date & note', 'তারিখ ও নোট'],
    'date': ['Submission date', 'জমাদানের তারিখ'],
    'note': ['Extra note (optional)', 'অতিরিক্ত নোট (ঐচ্ছিক)'],

    // ── Cover labels ──
    'assignment': ['Assignment', 'অ্যাসাইনমেন্ট'],
    'no': ['No.', 'নং'],
    'submittedTo': ['Submitted to', 'জমাদান করা হয়েছে'],
    'submittedBy': ['Submitted by', 'জমাদানকারী'],
    'dateLabel': ['Date of submission', 'জমাদানের তারিখ'],
    'phInstitution': ['Institution Name', 'প্রতিষ্ঠানের নাম'],
    'phDepartment': ['Department Name', 'বিভাগের নাম'],
    'phTitle': ['Assignment Title', 'অ্যাসাইনমেন্টের শিরোনাম'],
    'phCourse': ['Course Title', 'কোর্সের নাম'],
    'phName': ['Student Name', 'শিক্ষার্থীর নাম'],
    'phId': ['ID', 'আইডি'],
    'phTeacher': ['Teacher Name', 'শিক্ষকের নাম'],

    // ── Gallery ──
    'all': ['All', 'সব'],
    'styleMinimal': ['Minimal', 'মিনিমাল'],
    'styleModern': ['Modern', 'মডার্ন'],
    'styleClassic': ['Classic', 'ক্লাসিক'],
    'styleColorful': ['Colorful', 'কালারফুল'],
    'styleUniversity': ['University', 'ইউনিভার্সিটি'],
    'catSchool': ['School', 'স্কুল'],
    'catCollege': ['College', 'কলেজ'],
    'catUniversity': ['University', 'বিশ্ববিদ্যালয়'],

    // ── Customize ──
    'primaryColor': ['Primary color', 'প্রাইমারি কালার'],
    'secondaryColor': ['Secondary color', 'সেকেন্ডারি কালার'],
    'font': ['Font', 'ফন্ট'],
    'border': ['Border style', 'বর্ডার স্টাইল'],
    'borderSolid': ['Solid', 'সলিড'],
    'borderDouble': ['Double', 'ডাবল'],
    'borderNone': ['None', 'নেই'],
    'alignment': ['Alignment', 'অ্যালাইনমেন্ট'],
    'alignLeft': ['Left', 'বামে'],
    'alignCenter': ['Center', 'মাঝে'],
    'logoPosition': ['Logo position', 'লোগোর অবস্থান'],
    'logoTop': ['Top', 'উপরে'],
    'logoSide': ['Side', 'পাশে'],
    'compact': ['Compact spacing', 'কমপ্যাক্ট স্পেসিং'],
  };
}

// ═══════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════

/// true = Bangla, false = English.
final languageProvider = StateProvider<bool>((ref) => true);

/// Read-only strings provider — rebuilds whenever language changes.
final stringsProvider = Provider<AppStrings>(
  (ref) => AppStrings(ref.watch(languageProvider)),
);

/// Convenience: language code ('bn' | 'en') as a provider.
final localeCodeProvider = Provider<String>(
  (ref) => ref.watch(stringsProvider).localeCode,
);