import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundScoreField extends StatefulWidget {
  final int? score;
  final ValueChanged<int?> onChanged;
  final bool enabled;
  final String scoreFilter;

  const RoundScoreField({
    super.key,
    required this.score,
    required this.onChanged,
    this.enabled = true,
    this.scoreFilter = '',
  });

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
  }

  void _onFocusChange() {
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
            const SnackBar(
              content: Text('Invalid Score for this round'),
              duration: Duration(seconds: 2),
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
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: 'Score',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        border: const OutlineInputBorder(),
        filled: !widget.enabled,
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
