import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fs_score_card/l10n/app_localizations.dart';

class RoundScoreField extends StatefulWidget {
  const RoundScoreField({
    super.key,
    required this.score,
    required this.onChanged,
    this.scoreFilter = '',
    this.autofocus = false,
    this.onSubmitted,
  });
  final int? score;
  final ValueChanged<int?> onChanged;
  final String scoreFilter;
  final bool autofocus;
  final VoidCallback? onSubmitted;

  @override
  State<RoundScoreField> createState() => _RoundScoreFieldState();
}

class _RoundScoreFieldState extends State<RoundScoreField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasValidationError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.score?.toString() ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant RoundScoreField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.score?.toString() ?? '';
    if (_controller.text != newText) {
      _controller.text = newText;
    }
    if (oldWidget.scoreFilter != widget.scoreFilter) {
      _validateInput(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    if (widget.scoreFilter.isEmpty || value.isEmpty) {
      setState(() {
        _hasValidationError = false;
      });
      return;
    }

    final regex = RegExp(widget.scoreFilter);
    if (!regex.hasMatch(value)) {
      setState(() {
        _hasValidationError = true;
      });
    } else {
      setState(() {
        _hasValidationError = false;
      });
    }
  }

  void _onFieldSubmitted(String value) {
    if (_hasValidationError) {
      // Keep focus on the field if validation fails
      _focusNode.requestFocus();
      return;
    }

    // Only call onChanged if validation passes
    final parsed = int.tryParse(value);
    widget.onChanged(parsed);
    widget.onSubmitted?.call();
  }

  void _onFocusChange() {
    // Select all text when field gains focus (especially for autofocus)
    if (_focusNode.hasFocus && widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.text.isNotEmpty) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      });
    }
    // If the field is about to lose focus and has a validation error, prevent it
    if (!_focusNode.hasFocus &&
        _hasValidationError &&
        _controller.text.isNotEmpty) {
      // Re-request focus to prevent leaving the field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
          // Show SnackBar message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidScoreForRound),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _onInputChanged(String value) {
    _validateInput(value);

    // If the input is valid, update the score immediately for real-time total calculation
    if (!_hasValidationError && value.isNotEmpty) {
      final parsed = int.tryParse(value);
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.scoreHint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        border: const OutlineInputBorder(),
      ),
      onChanged: _onInputChanged,
      onFieldSubmitted: _onFieldSubmitted,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onTap: () {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      },
    );
  }
}
