import 'package:flutter/material.dart';

class PlayerNameField extends StatefulWidget {
  final String name;
  final ValueChanged<String> onChanged;

  const PlayerNameField({
    super.key,
    required this.name,
    required this.onChanged,
  });

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
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontWeight: FontWeight.bold),
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
