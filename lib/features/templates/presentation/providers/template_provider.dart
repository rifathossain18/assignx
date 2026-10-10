import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/template_config.dart';
import '../../domain/template_info.dart';
import '../templates/template_registry.dart';

class TemplateConfigNotifier extends Notifier<TemplateConfig> {
  @override
  TemplateConfig build() => TemplateRegistry.all.first.defaultConfig();

  /// Choosing a template resets colours/font to that template's defaults.
  void select(TemplateInfo template) => state = template.defaultConfig();

  void update(TemplateConfig Function(TemplateConfig current) change) {
    state = change(state);
  }

  void replace(TemplateConfig config) => state = config;
}

final templateConfigProvider =
    NotifierProvider<TemplateConfigNotifier, TemplateConfig>(
  TemplateConfigNotifier.new,
);