import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  final Stream<String> stream;
  final Function(String) onChanged;

  const InputField(this.icon, this.hint, this.obscure, this.stream, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        return TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            errorText: snapshot.error?.toString(),
            contentPadding: const EdgeInsets.only(left: 5, right: 30, top: 40, bottom: 30),
            icon: Icon(icon, color: Colors.white),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white),
            focusedBorder: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          obscureText: obscure,
        );
      },
    );
  }
}
