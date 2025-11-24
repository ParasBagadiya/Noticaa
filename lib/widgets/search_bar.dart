import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search notes by title or content...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear();
                  widget.onChanged('');
                },
              )
            : null,
      ),
      style: TextStyle(color: Colors.white),
      onChanged: widget.onChanged,
    );
  }
}
