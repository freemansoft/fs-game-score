import 'package:flutter/material.dart';

class PlayerNameField extends StatefulWidget {
  const PlayerNameField({
    super.key,
    required this.name,
    required this.onChanged,
    this.border,
    this.textAlign = TextAlign.center,
  });
  final String name;
  final ValueChanged<String> onChanged;
  final InputBorder? border;
  final TextAlign textAlign;

  @override
  State<PlayerNameField> createState() => _PlayerNameFieldState();
}

class _PlayerNameFieldState extends State<PlayerNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant PlayerNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name && _controller.text != widget.name) {
      _controller.text = widget.name;
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
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: widget.border != null
            ? const EdgeInsets.symmetric(vertical: 12, horizontal: 12)
            : const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        border: widget.border ?? InputBorder.none,
        enabledBorder: widget.border,
        focusedBorder: widget.border,
      ),
      style: const TextStyle(fontWeight: FontWeight.normal),
      onChanged: widget.onChanged,
      onTap: () {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      },
    );
  }
}
