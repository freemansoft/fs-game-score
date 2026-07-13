import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:fs_score_lints/src/localize_semantic_labels.dart';

/// Entry point discovered by `custom_lint`.
PluginBase createPlugin() => _FsScoreLints();

class _FsScoreLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const LocalizeSemanticLabels(),
      ];
}
