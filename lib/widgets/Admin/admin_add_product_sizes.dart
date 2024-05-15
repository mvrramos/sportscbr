// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/widgets/Admin/admin_add_size_dialog.dart';

class AdminProductSizes extends FormField<List> {
  AdminProductSizes(
    BuildContext context, {
    super.key,
    required List super.initialValue,
    required FormFieldSetter<List> super.onSaved,
    required FormFieldValidator<List> super.validator,
  }) : super(builder: (state) {
          return SizedBox(
            height: 40,
            child: GridView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
                childAspectRatio: 0.5,
              ),
              children: state.value!.map<Widget>((s) {
                return GestureDetector(
                  onLongPress: () {
                    state.didChange(state.value!..remove(s));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: Colors.grey, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList()
                ..add(
                  GestureDetector(
                    onTap: () async {
                      String? size = await showCupertinoDialog(
                        context: context,
                        builder: (context) => AdminAddSizeDialog(),
                      );
                      if (size != null) {
                        state.didChange(state.value!..add(size));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "+",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ),
          );
        });
}