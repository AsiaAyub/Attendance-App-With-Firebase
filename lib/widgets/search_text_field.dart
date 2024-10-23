// lib/widgets/search_text_field.dart

import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final Function(String) onChanged;

  const SearchTextField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      autofocus: true,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),

      //to trigger the keyboard search button
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
        hintText: 'Search',
        hintStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
