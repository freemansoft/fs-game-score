import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundScoreField extends StatefulWidget {
  final int? score;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  const RoundScoreField({
    super.key,
    required this.score,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<RoundScoreField> createState() => _RoundScoreFieldState();
}

class _RoundScoreFieldState extends State<RoundScoreField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.score?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant RoundScoreField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.score?.toString() ?? '';
    if (_controller.text != newText) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: 'Score',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        border: const OutlineInputBorder(),
        filled: !widget.enabled,
      ),
      onChanged: (val) {
        final parsed = int.tryParse(val);
        widget.onChanged(parsed);
      },
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
