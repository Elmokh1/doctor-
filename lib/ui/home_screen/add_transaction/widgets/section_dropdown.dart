import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../data/model/sections_model.dart';
import '../../../../data/my_dataBase.dart';

class SectionDropdown extends StatelessWidget {
  final bool isIncome;
  final Function(SectionsModel) onSectionSelected;

  const SectionDropdown({
    required this.isIncome,
    required this.onSectionSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MyDatabase.getSectionsRealTimeUpdate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final sections = snapshot.data!.docs
            .map((e) => e.data())
            .cast<SectionsModel>()
            .where((s) => s.isIncome == isIncome)
            .toList();

        if (sections.isEmpty) return Text("no_sections_available".tr());

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "select_section".tr(),
            border: const OutlineInputBorder(),
          ),
          items: sections
              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name ?? "")))
              .toList(),
          onChanged: (value) {
            final selected = sections.firstWhere(
                  (s) => s.id == value,
              orElse: () => sections[0],
            );
            onSectionSelected(selected);
          },
        );
      },
    );
  }
}
