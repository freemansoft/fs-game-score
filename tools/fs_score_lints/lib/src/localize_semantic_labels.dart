import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags accessibility labels that are hardcoded string literals.
///
/// `semanticLabel:` / `semanticsLabel:` (any widget) and `label:` on a
/// `Semantics(...)` are read aloud by screen readers, so they are user-facing
/// text and must be localized via `AppLocalizations`, not baked in as a
/// `'...'` literal. Violations surface live in the IDE and via
/// `dart run custom_lint`.
///
/// Canonical rule: .agents/skills/fs-game-score-flutter-patterns/SKILL.md.
class LocalizeSemanticLabels extends DartLintRule {
  const LocalizeSemanticLabels() : super(code: _code);

  static const _code = LintCode(
    name: 'localize_semantic_labels',
    problemMessage:
        'Accessibility labels are read by screen readers and must be '
        'localized via AppLocalizations, not hardcoded string literals.',
    correctionMessage:
        'Use a *Label-suffixed l10n key: '
        'AppLocalizations.of(context)!.yourLabel(...).',
    errorSeverity: ErrorSeverity.WARNING,
  );

  /// Named arguments that are always screen-reader labels, on any widget.
  static const _labelArgNames = {'semanticLabel', 'semanticsLabel'};

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // semanticLabel: / semanticsLabel: anywhere.
    context.registry.addNamedExpression((node) {
      if (_labelArgNames.contains(node.name.label.name) &&
          _isHardcoded(node.expression)) {
        reporter.atNode(node.expression, _code);
      }
    });

    // label: only when the enclosing constructor is Semantics(...).
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme != 'Semantics') return;
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression &&
            arg.name.label.name == 'label' &&
            _isHardcoded(arg.expression)) {
          reporter.atNode(arg.expression, _code);
        }
      }
    });
  }

  /// A string literal — plain or interpolated — is hardcoded. A call such as
  /// `l10n.fooLabel(...)` is a [MethodInvocation], not a [StringLiteral], so it
  /// passes.
  bool _isHardcoded(Expression expr) => expr is StringLiteral;
}
