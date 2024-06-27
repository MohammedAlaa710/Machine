import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class MyDropdownSearch extends StatelessWidget {
  final String? fromto;
  final Set<String> items;
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  const MyDropdownSearch({
    super.key,
    required this.fromto,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: fromto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      popupProps: const PopupProps.dialog(
        showSearchBox: true,
        showSelectedItems: true,
      ),
      items: items.toList(),
      onChanged: (value) => onChanged(value),
      selectedItem: selectedValue.isNotEmpty ? selectedValue : null,
    );
  }
}
